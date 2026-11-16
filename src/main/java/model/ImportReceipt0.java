package model;

import java.util.ArrayList;
import java.util.List;

public class ImportReceipt0 {
    private int id;
    private java.sql.Date importDate;
    private String status;
    private Supplier0 supplier;
    private WarehouseStaff0 warehouseStaff;
    private List<ImportReceiptDetail0> importReceiptDetail = new ArrayList<>();

    public ImportReceipt0() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public java.sql.Date getImportDate() { return importDate; }
    public void setImportDate(java.sql.Date importDate) { this.importDate = importDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Supplier0 getSupplier() { return supplier; }
    public void setSupplier(Supplier0 supplier) { this.supplier = supplier; }
    public WarehouseStaff0 getWarehouseStaff() { return warehouseStaff; }
    public void setWarehouseStaff(WarehouseStaff0 warehouseStaff) { this.warehouseStaff = warehouseStaff; }
    public List<ImportReceiptDetail0> getImportReceiptDetail() { return importReceiptDetail; }
    public void setImportReceiptDetail(List<ImportReceiptDetail0> importReceiptDetail) { this.importReceiptDetail = importReceiptDetail; }
}
