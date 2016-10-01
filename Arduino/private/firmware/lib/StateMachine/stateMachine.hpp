#ifndef STATEMACHINE_H
#define STATEMACHINE_H
#include <Arduino.h>

// This array size will allow us to do up to 1 second of readings at 1 ms intervals or 5 seconds at 5 ms intervals
#define MAX_SENSOR_READINGS 1000

// Time types representing milliseconds and microseconds
using timems_t = uint32_t;
using timeus_t = uint32_t;

/* Base class */
class StateMachine {

    protected:
        // TODO: If we want more precise timing we can internally use timeus_t but still have user specify timems_t
        //       If we do this we'll have to be much more careful about overflow
        timems_t tm_delay;
        timems_t tm_duration;
        timems_t tm_period;
        timems_t tm_start;
        timems_t tm_delay_actual;
        timems_t tm_duration_actual;
        timems_t tm_period_actual;
        int num_repeats;
        int repeat_counter;
        int current_state;
        void (*on_function)(int);   // Function pointer to function that should be called when state switches to ON
        void (*off_function)(int);   // Function pointer to function that should be called when state switches to OFF/INTERPULSE
        int function_arg;

    public:
        StateMachine();
        StateMachine(timems_t, timems_t, void (*)(int), void (*)(int), int);
        enum { OFF, INIT, ON, INTERPULSE };
        timems_t elapsedTime();
        void start();
        void stop();
        int update();
        virtual void on();  // use virtual so we can call derived method from method of base class
        virtual void off();  // use virtual so we can call derived method from method of base class
        void setDelay(timems_t);
        void setDuration(timems_t);
        void setFunctionArg(int);
        int checkState();
        timems_t checkDelayError();
        timems_t checkDurationError();
        timems_t checkPeriodError();
};

/* Stimulus class - single pulse */
class Stimulus : public StateMachine {

    public:
        Stimulus();
        // This constructor doesn't expose all of the available properties of base class (e.g. tm_period, num_repeats)
        Stimulus(timems_t delay, timems_t duration, void (*on)(int),void (*off)(int), int args) :
            StateMachine(delay,duration,on,off,args) {}
};

/* Repeating Stimulus class */
class StimulusRepeating : public StateMachine {

    public:
        StimulusRepeating();
        // Unlike simpler Stimulus class, this constructor exposes tm_period and num_repeats properties of base class
        // Another way to do it might be to have a constructor with this signature in base class in addition to its
        // current simpler signature that Stimulus uses and then feed parameters from this constructor to base constructor
        StimulusRepeating(timems_t, timems_t, void (*)(int), void (*)(int), int, timems_t, int);
        void setPeriod(timems_t);
        void setNumRepeats(int);
};

/* Repeating Sensor class */
class SensorRepeating : public StateMachine {

    protected:
        int current_sample;
        int32_t readings[MAX_SENSOR_READINGS];
        timems_t times[MAX_SENSOR_READINGS];
        // Function pointer to function that should be called when state switches to ON (to take a reading)
        void (*reading_function)(timems_t &, int32_t &);

    public:
        SensorRepeating();
        SensorRepeating(timems_t, void (*)(timems_t &, int32_t &), timems_t, int);
        void on();
        void off();
        timems_t getTime(int);
        int32_t getReading(int);
        void reset();
};

#endif
