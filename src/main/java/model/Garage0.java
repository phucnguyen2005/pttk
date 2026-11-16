package model;

import java.util.ArrayList;
import java.util.List;

public class Garage0 {
    private int id;
    private String name;
    private String address;
    private String contactPhoneNumber;
    private List<RepairBay0> repairBay = new ArrayList<>();
    private List<Warehouse0> warehouse = new ArrayList<>();
    private List<Staff0> staff = new ArrayList<>();

    public Garage0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getContactPhoneNumber() { return contactPhoneNumber; }
    public void setContactPhoneNumber(String contactPhoneNumber) { this.contactPhoneNumber = contactPhoneNumber; }
    public List<RepairBay0> getRepairBay() { return repairBay; }
    public void setRepairBay(List<RepairBay0> repairBay) { this.repairBay = repairBay; }
    public List<Warehouse0> getWarehouse() { return warehouse; }
    public void setWarehouse(List<Warehouse0> warehouse) { this.warehouse = warehouse; }
    public List<Staff0> getStaff() { return staff; }
    public void setStaff(List<Staff0> staff) { this.staff = staff; }
}
