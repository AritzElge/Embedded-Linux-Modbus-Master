#include <stdio.h>       // POSIX/Linux file I/O (printf, stderr, fopen, fscanf)
#include <unistd.h>      // POSIX functions (sleep())
#include <time.h>        // POSIX functions (nanosleep(), struct timespec)
#include <mraa/gpio.h>   // MRAA GPIO library
#include <mraa/common.h> // MRAA common definitions
#include <fcntl.h>       // POSIX file control (open, read)
#include <sys/stat.h>    // POSIX file stats (open, read)
#include <dirent.h>      // POSIX directory handling (opendir, readdir)
#include <string.h>      // Standard C string handling
#include <stdlib.h>      // Standard C library (atoi, exit)
#include <limits.h>      // INCLUDE THIS HEADER TO USE PATH_MAX/NAME_MAX

// Time definitions
#define T_SHORT_S  0L
#define T_SHORT_NS 200000000       // Short Blink (200ms)
#define T_LONG_S   0L
#define T_LONG_NS  600000000       // Long Blink (600ms)
#define T_OFF_SYNC 2               // Long synchronization pause (2 seconds)
#define T_ON_HEARTBEAT 100000000   // On time for heartbeat blink (100ms)

#define STATUS_DIR "/tmp/status/"  // Directory containing daemon status files

// MUX GPIO pinout (Configured in main)
#define IO_EXP_MUX_SEL1 30  
#define IO_EXP_MUX_SEL2 31  
#define QUARK_GPIO_46   46  

// -- Function Prototypes (Declarations) --
int get_operation_status(void);
void do_blink(mraa_gpio_context gpio_pin, int seconds, int nanoseconds);
void blink_error_code(mraa_gpio_context led_gpio_pin, int error_code);
int configure_gpio_output_raw(mraa_gpio_context gpio_pin);


// -- Function Implementations (Definitions) --

/** int get_operation_status()
 * @brief Reads status files in /tmp/status/ and returns the highest error code.
 * @return An integer (0=OK, >0=Error code). Returns 15 if status dir not found.
 */
int get_operation_status()
{
    DIR *d;
    struct dirent *dir;
    int highest_error = 0;
    
    d = opendir(STATUS_DIR);
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            // Skip "." and ".." directory entries
            if (strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0) {
                continue;
            }

            char path[PATH_MAX]; 
            snprintf(path, sizeof(path), "%s%s", STATUS_DIR, dir->d_name);
            
            FILE *fp = fopen(path, "r");
            if (fp != NULL) {
                // Use fscanf to read an integer number (can be multiple digits)
                int status_code = 0;
                if (fscanf(fp, "%d", &status_code) == 1) {
                    if (status_code > highest_error) {
                        highest_error = status_code;
                    }
                }
                // If fscanf fails to read a number, it skips the comparison logic.
                fclose(fp);
            } else {
                fprintf(stderr, "ERROR: Could not open status file %s\n", path);
                // Error 15 now indicates "Cannot read status file"
                if (highest_error == 0) highest_error = 15; 
            }
        }
        closedir(d);
    } else {
        fprintf(stderr, "WARNING: Status directory %s not found.\n", STATUS_DIR);
        // Error 15 also for "Status directory missing"
        return 15; 
    }

    return highest_error;
}


/**
 * @brief Toggles a GPIO pin state (ON/OFF sequence) with specific delays.
 *
 * This function turns the specified GPIO pin on for a defined duration (seconds/nanoseconds ON time), 
 * then turns it off for a standard short duration (T_SHORT_S/T_SHORT_NS OFF time).
 * 
 * @param gpio_pin The MRAA GPIO context object representing the physical pin.
 * @param seconds The number of seconds the pin should remain ON.
 * @param nanoseconds The number of nanoseconds the pin should remain ON.
 */
void do_blink(mraa_gpio_context gpio_pin, int seconds, int nanoseconds)
{
    struct timespec ts_on = { .tv_sec = seconds, .tv_nsec =nanoseconds };
    struct timespec ts_off = { .tv_sec = T_SHORT_S, .tv_nsec = T_SHORT_NS }; 

    mraa_gpio_write(gpio_pin, 1);
    nanosleep(&ts_on, NULL);
    mraa_gpio_write(gpio_pin, 0);
    nanosleep(&ts_off, NULL);
}

/**
 * @brief Blinks a specific 4-bit error code sequence on a GPIO pin.
 *
 * This function takes an integer error code, processes its 4 least significant bits, 
 * and translates each bit into a distinct blink pattern using do_blink(). 
 * A '1' bit results in a long blink duration, while a '0' bit results in a short 
 * blink duration. A synchronization delay occurs before the sequence starts.
 *
 * @param led_gpio_pin The MRAA GPIO context object representing the physical LED pin.
 * @param error_code The integer value representing the error code to be signaled (only LSB 4 bits used).
 */
void blink_error_code(mraa_gpio_context led_gpio_pin, int error_code)
{
    sleep(T_OFF_SYNC); 

    // Iterate only 4 times (from 3 down to 0) instead of 8
    for (int i = 3; i >= 0; i--) 
    {
        int bit = (error_code >> i) & 1;

        if (bit == 1)
        {
            do_blink(led_gpio_pin, T_LONG_S, T_LONG_NS);
        }
        else
        {
            do_blink(led_gpio_pin, T_SHORT_S, T_SHORT_NS);
        }
    }
}

/**
 * @brief Configures a given MRAA GPIO pin context for output direction.
 *
 * This function sets the specified GPIO pin direction to output mode using the 
 * MRAA library. It performs basic validation to ensure the context object is valid
 * before attempting configuration.
 *
 * @param gpio_pin The MRAA GPIO context object representing the physical pin.
 * @return Returns 0 on success, 99 if the initial GPIO context is NULL, 
 *         or an MRAA error code integer if setting the direction fails.
 */
int configure_gpio_output_raw(mraa_gpio_context gpio_pin)
{
  mraa_result_t result = MRAA_SUCCESS;
  
  if (gpio_pin == NULL)
    { 
        fprintf(stderr, "MRAA Init Error. Check configuration.\n");
        return 99; 
    }

    result = mraa_gpio_dir(gpio_pin, MRAA_GPIO_OUT);

    if (result != MRAA_SUCCESS)
    {
        fprintf(stderr, "MRAA DIrection Error\n");
        return (int)result;
    }

    return 0;
}


int main()
{
    // Initialize MRAA library and configure MUX (your original main logic)
    mraa_init();
    {
        int mux_gpio[] = {IO_EXP_MUX_SEL1, IO_EXP_MUX_SEL2, QUARK_GPIO_46}; 
        for (int i_gpio = 0; i_gpio < 3; i_gpio++)
        {
            mraa_gpio_context mux_gpio_pin = mraa_gpio_init_raw(mux_gpio[i_gpio]);
            if (0 != configure_gpio_output_raw(mux_gpio_pin))
            {
                return 1;
            }
            mraa_gpio_write(mux_gpio_pin, 0);
        }
    }

    mraa_gpio_context led_gpio_pin = mraa_gpio_init_raw(7);
    if (0 != configure_gpio_output_raw(led_gpio_pin))
    {
        return 1;
    }
    
    // Main loop: Continuously check status and blink
    while(1)
    {
        int current_status = get_operation_status(); 

        if (current_status == 0)
	{
            // OK Status: Heartbeat activated
            struct timespec ts_on = { .tv_sec = 0L, .tv_nsec = T_ON_HEARTBEAT };
            mraa_gpio_write(led_gpio_pin, 1);
            nanosleep(&ts_on, NULL);
            mraa_gpio_write(led_gpio_pin, 0);
            // The long pause is handled by the main sleep(1) outside the if/else
        }
        else
        {
            // Error status: Blink the code
            blink_error_code(led_gpio_pin, current_status);
            // The long pause is handled by the main sleep(1) outside the if/else
        }
        
        // Main loop pause of 1 second to control the frequency of the loop
        sleep(1);
    }

    return 0;
}
