#include <stdio.h>    // Permitido en POSIX/Linux user-space
#include <unistd.h>   // Funciones POSIX como usleep()
#include <time.h>     // Funciones POSIX como time() y difftime()
#include <mraa/gpio.h>
#include <mraa/common.h>

// Time definitions in microseconds (usleep)
#define T_SHORT_S  0L
#define T_SHORT_NS 200000000// Short Blink
#define T_LONG_S   0L
#define T_LONG_NS  600000000// Long Blink
#define T_OFF_SYNC 2        // Long synchronization pause
#define T_ON_HEARTBEAT 100000000   // On time for heartbeat blink
#define T_OFF_HEARTBEAT 900000000  // OFF time for heartbeat blink

// MUX GPIO pinout
#define IO_EXP_MUX_SEL1 30  // I/O Expander MUX Select 1
#define IO_EXP_MUX_SEL2 31  // I/O Expander MUX Select 2
#define QUARK_GPIO_46   46  // Quark GPIO 46

// -- Function Prototypes (Declarations) --
int get_operation_status(void);
void do_blink(mraa_gpio_context gpio_pin, int seconds, int nanoseconds);
void blink_error_code(mraa_gpio_context led_gpio_pin, int error_code);
int configure_gpio_output_raw(mraa_gpio_context gpio_pin);


// -- Function Implementations (Definitions) --

/** int get_operation_status()
 * @brief Stub function that will return the actual error code
 * @return An integer (e.g.: 0=OK, 1=SPI Error, 2=Modbus Error, 3=Memory Error)
 */
int get_operation_status()
{
    // Warning!!!No error detection implemented yet!!!
    return 0; // Simulation: OK=0
}

/** void do_blink(mraa_gpio_context gpio_pin, int duration)
 * @brief Performs a single blink (on/off) with a specific duration
 * @param gpio_pin The MRAA GPIO context for the pin being used
 * @param duration Duration of the ON state and a short OFF state
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

/** void blink_error_code(mraa_gpio_context led_gpio_pin, int error_code)
 * @brief Blinks a binary error code using long/short blinks
 * @param led_gpio_pin The MRAA GPIO context for the LED pin
 * @param error_code The code to blink (only the first 8 bits)
 */
void blink_error_code(mraa_gpio_context led_gpio_pin, int error_code)
{
    sleep(T_OFF_SYNC); 

    for (int i = 7; i >= 0; i--)
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
    
    sleep(T_OFF_SYNC);
}

/** int configure_gpio_output_raw(mraa_gpio_context gpio_pin)
 * @brief Configures a GPIO pin context as an output
 * @param gpio_pin The MRAA GPIO context
 * @return 0 on success, or an MRAA error code (>0) on failure
 */
int configure_gpio_output_raw(mraa_gpio_context gpio_pin)
{
  mraa_result_t result = MRAA_SUCCESS;
  
  if (gpio_pin == NULL)
    { 
        fprintf(stderr, "MRAA Init Error. Check configuration.\n");
        if (result == 0)
        {
          return 99;
        }
    }

    // We capture result from mraa_gpio_dir
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
    int status = 0; // 0 for OK and >0 for error

    mraa_init();
    {
      int mux_gpio[3] = {IO_EXP_MUX_SEL1, IO_EXP_MUX_SEL2, QUARK_GPIO_46};
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
    configure_gpio_output_raw(led_gpio_pin);
    
    // Main loop: Uses status for correct operation or error code
    while(1)
    {
        if (status == 0)
	{
	    struct timespec ts_on = { .tv_sec = 0L, .tv_nsec = T_ON_HEARTBEAT };
	    struct timespec ts_off = { .tv_sec = 0L, .tv_nsec = T_OFF_HEARTBEAT };
            // OK Status: Heatbeat activated
            mraa_gpio_write(led_gpio_pin, 1);
            nanosleep(&ts_on, NULL);
            mraa_gpio_write(led_gpio_pin, 0);
            nanosleep(&ts_off, NULL);
        }
        else
        {
            // Error status
            blink_error_code(led_gpio_pin, status);
        }
    }

    return 0;
}

