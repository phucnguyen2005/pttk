package model;

import java.util.ArrayList;
import java.util.List;

public class Customer0 extends Member0 {
    private List<Appointment0> appointment = new ArrayList<>();
    private List<Vehicle0> vehicle = new ArrayList<>();

    public Customer0() {}

    public List<Appointment0> getAppointment() { return appointment; }
    public void setAppointment(List<Appointment0> appointment) { this.appointment = appointment; }
    public List<Vehicle0> getVehicle() { return vehicle; }
    public void setVehicle(List<Vehicle0> vehicle) { this.vehicle = vehicle; }
}
