package model;

import java.util.ArrayList;
import java.util.List;

public class Invoice0 {
    private int id;
    private java.sql.Timestamp issueDate;
    private int totalAmount;
    private String status;
    private SalesStaff0 salesStaff;
    private TechnicalStaff0 technicalStaff;
    private Vehicle0 vehicle;
    private List<InvoiceServiceDetail0> invoiceServiceDetail = new ArrayList<>();
    private List<InvoicePartDetail0> invoicePartDetail = new ArrayList<>();

    public Invoice0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public java.sql.Timestamp getIssueDate() { return issueDate; }
    public void setIssueDate(java.sql.Timestamp issueDate) { this.issueDate = issueDate; }
    public int getTotalAmount() { return totalAmount; }
    public void setTotalAmount(int totalAmount) { this.totalAmount = totalAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public SalesStaff0 getSalesStaff() { return salesStaff; }
    public void setSalesStaff(SalesStaff0 salesStaff) { this.salesStaff = salesStaff; }
    public TechnicalStaff0 getTechnicalStaff() { return technicalStaff; }
    public void setTechnicalStaff(TechnicalStaff0 technicalStaff) { this.technicalStaff = technicalStaff; }
    public Vehicle0 getVehicle() { return vehicle; }
    public void setVehicle(Vehicle0 vehicle) { this.vehicle = vehicle; }
    public List<InvoiceServiceDetail0> getInvoiceServiceDetail() { return invoiceServiceDetail; }
    public void setInvoiceServiceDetail(List<InvoiceServiceDetail0> invoiceServiceDetail) { this.invoiceServiceDetail = invoiceServiceDetail; }
    public List<InvoicePartDetail0> getInvoicePartDetail() { return invoicePartDetail; }
    public void setInvoicePartDetail(List<InvoicePartDetail0> invoicePartDetail) { this.invoicePartDetail = invoicePartDetail; }
}
