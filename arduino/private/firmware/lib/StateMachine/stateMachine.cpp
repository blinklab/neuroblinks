#include "stateMachine.hpp"
#include <Arduino.h>

/* Base class */
StateMachine::StateMachine() {
    tm_delay = 0;
    tm_duration = 0;
    tm_period = 0;
    num_repeats = 1;
    current_state = INIT;
    on_function = 0;
    off_function = 0;
    function_arg = 0;
}

StateMachine::StateMachine(timems_t delay, timems_t duration, void (*on)(int), void (*off)(int), int arg) {
    tm_delay = delay;
    tm_duration = duration;
    tm_period = 0;
    num_repeats = 1;
    current_state = INIT;
    on_function = on;
    off_function = off;
    function_arg = arg;
}

void StateMachine::start() {
    tm_start = millis();
    current_state = INIT;
}

void StateMachine::stop() {
    current_state = OFF;
}

timems_t StateMachine::elapsedTime() {
    timems_t now = millis();
    return (now - tm_start);
}

int StateMachine::update() {
    // Check elapsed time and update states if necessary
    timems_t et = elapsedTime();

    if (et >= tm_delay && current_state == INIT) {
        repeat_counter = num_repeats;
        current_state = ON;
        tm_delay_actual = elapsedTime();
        on();
        tm_start = millis();
        return current_state;
    }

    if (et >= tm_duration && current_state == ON) {
        current_state = INTERPULSE;
        repeat_counter--;
        tm_duration_actual = elapsedTime();
        off();
        tm_start = millis();
        if (repeat_counter == 0) { current_state = OFF; }
        return current_state;
    }

    if (et >= (tm_period - tm_duration) && current_state == INTERPULSE) {
        current_state = ON;
        tm_period_actual = elapsedTime();
        on();
        tm_start = millis();
        return current_state;
    }

    return -1;
}

void StateMachine::on() {

   // std::cout << "Pin " << function_arg << " Actual delay: " << tm_delay_actual << " \n";
    (*on_function)(function_arg);

}

void StateMachine::off() {

   // std::cout << "Pin " << function_arg<< " Actual duration: " << tm_duration_actual << " \n";
    (*off_function)(function_arg);

}

int StateMachine::checkState() {

    return (current_state);

}

timems_t StateMachine::checkDelayError() { return (tm_delay_actual - tm_delay); }

timems_t StateMachine::checkDurationError() { return (tm_duration_actual - tm_duration); }

timems_t StateMachine::checkPeriodError() { return (tm_period_actual - tm_period); }

void StateMachine::setDelay(timems_t delay) { tm_delay = delay; }

void StateMachine::setDuration(timems_t duration) { tm_duration = duration; }

void StateMachine::setFunctionArg(int arg) { function_arg = arg; }


/* Stimulus class */
// Nothing needed because fully inherits from base class

/* Repeating stimulus class */
StimulusRepeating::StimulusRepeating(timems_t delay, timems_t duration, void (*on)(int), void (*off)(int), int pin, timems_t period, int repeats) {
    tm_delay = delay;
    tm_duration = duration;
    current_state = INIT;
    on_function = on;
    off_function = off;
    function_arg = pin;
    tm_period = period;
    num_repeats = repeats;
}

void StimulusRepeating::setPeriod(timems_t period) { tm_period = period; }

void StimulusRepeating::setNumRepeats(int n_repeats) { num_repeats = n_repeats; }

/* Repeating sensor class */
SensorRepeating::SensorRepeating() {
    tm_delay = 0;
    tm_duration = 1;
    current_state = INIT;
    on_function = 0;
    off_function = 0;
    function_arg = 0;
    reading_function = 0;
    tm_period = 0;
    num_repeats = 1;
    current_sample = 0;
}

SensorRepeating::SensorRepeating(timems_t del, void (*read_fun)(timems_t &, int32_t &), timems_t period, int repeats) {
    tm_delay = del;
    tm_duration = 1;
    current_state = INIT;
    on_function = 0;
    off_function = 0;
    function_arg = 0;
    reading_function = read_fun;
    tm_period = period;
    num_repeats =  repeats;
    current_sample = 0;

}


void SensorRepeating::on() {

    if (current_sample >= 0 && current_sample< num_repeats) {
        timems_t time;
        int32_t reading;

        // Call function to fill values (function is defined by user)
        (*reading_function)(time,reading);

        times[current_sample] = time;
        readings[current_sample] = reading;

        current_sample++;
    }

}

void SensorRepeating::off() {
    // Override this method if you want to do something when state goes to off

}

timems_t SensorRepeating::getTime(int index) {
    if (index >= 0 && index < num_repeats) {
        return (times[index]);
    }
}

int32_t SensorRepeating::getReading(int index) {
    if (index >= 0 && index < num_repeats) {
        return (readings[index]);
    }
}

void SensorRepeating::reset() {
    current_sample = 0;
    for (int i=0; i<MAX_SENSOR_READINGS; i++) {
        times[i] = 0;
        readings[i] = 0;
    }
}
