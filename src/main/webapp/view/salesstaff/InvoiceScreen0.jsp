<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,dao.*,java.util.*,java.text.*,java.net.URLEncoder" %>
<%!
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    static int toInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return -1; }
    }
    static String enc(String s) throws java.io.UnsupportedEncodingException {
        return URLEncoder.encode(s == null ? "" : s, "UTF-8");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("member") == null || !"sales".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginScreen0.jsp"); return;
    }
    int customerId = toInt(request.getParameter("customerId"));
    int paidInvoiceId = toInt(request.getParameter("paidInvoice"));
    String addKeyword = request.getParameter("inAddKeyword");
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");

    // ---------------- POST: subAdd (add lines, recalculate) or subConfirm ----------------
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        String back = "InvoiceScreen0.jsp?customerId=" + customerId + "&inAddKeyword=" + enc(addKeyword);
        CustomerDAO customerDAO = new CustomerDAO();
        InvoiceDAO invoiceDAO = new InvoiceDAO();
        InvoicePartDetailDAO partDetailDAO = new InvoicePartDetailDAO();
        InvoiceServiceDetailDAO serviceDetailDAO = new InvoiceServiceDetailDAO();
        ServiceDAO serviceDAO = new ServiceDAO();
        PartDAO partDAO = new PartDAO();
        try {
            Customer0 customer = customerDAO.getCustomer(customerId);
            Invoice0 invoice = customer == null ? null : invoiceDAO.getInvoiceByCustomer(customer);  // getInvoiceByCustomer()
            if (invoice == null) {
                back += "&err=" + enc("Khách hàng không có hóa đơn chưa thanh toán.");
            } else if ("add".equals(action)) {                                                       // subAdd
                int added = 0;
                List<String> failed = new ArrayList<>();
                for (Enumeration<String> names = request.getParameterNames(); names.hasMoreElements();) {
                    String n = names.nextElement();
                    boolean isPart = n.startsWith("qtyP_");
                    if (!isPart && !n.startsWith("qtyS_")) continue;
                    int id = toInt(n.substring(5));
                    int qty = toInt(request.getParameter(n));
                    if (id <= 0 || qty <= 0) continue;                         // only rows with quantity > 0
                    if (isPart) {
                        Part0 p = partDAO.getPartDetail(id);
                        if (p != null && partDetailDAO.addPartDetail(invoice, p, qty)) added++;   // addPartDetail()
                        else failed.add(p == null ? "phụ tùng #" + id : p.getName() + " (không đủ tồn kho?)");
                    } else {
                        Service0 s = serviceDAO.getServiceDetail(id);
                        if (s != null && serviceDetailDAO.addServiceDetail(invoice, s)) added++;  // addServiceDetail()
                        else failed.add(s == null ? "dịch vụ #" + id : s.getName());
                    }
                }
                invoiceDAO.calculateTotalAmount(invoice);                                         // calculateTotalAmount()
                if (added > 0) back += "&msg=" + enc("Đã thêm " + added + " dòng vào hóa đơn.");
                else if (failed.isEmpty()) back += "&err=" + enc("Chưa nhập số lượng cho dòng nào.");
                if (!failed.isEmpty()) back += "&err=" + enc("Không thêm được: " + String.join(", ", failed));
            } else if ("confirm".equals(action)) {                                                   // subConfirm
                if (invoiceDAO.confirmInvoice(invoice)) {                                            // confirmInvoice()
                    back = "InvoiceScreen0.jsp?customerId=" + customerId + "&paidInvoice=" + invoice.getId();
                } else {
                    back += "&err=" + enc("Xác nhận hóa đơn không thành công. Hóa đơn cần có ít nhất một dịch vụ/phụ tùng và tổng tiền lớn hơn 0.");
                }
            }
        } finally {
            customerDAO.close(); invoiceDAO.close(); partDetailDAO.close();
            serviceDetailDAO.close(); serviceDAO.close(); partDAO.close();
        }
        response.sendRedirect(back);
        return;
    }

    // ---------------- GET: show the invoice (+ suggestions) ----------------
    CustomerDAO customerDAO = new CustomerDAO();
    InvoiceDAO invoiceDAO = new InvoiceDAO();
    ServiceDAO serviceDAO = new ServiceDAO();
    PartDAO partDAO = new PartDAO();
    Customer0 customer = null;
    Invoice0 inv = null;
    boolean justPaid = paidInvoiceId > 0;
    List<Service0> suggestServices = new ArrayList<>();
    List<Part0> suggestParts = new ArrayList<>();
    boolean searched = addKeyword != null && !justPaid;
    try {
        customer = customerDAO.getCustomer(customerId);
        if (customer != null) {
            inv = justPaid ? invoiceDAO.getInvoiceDetail(paidInvoiceId)
                           : invoiceDAO.getInvoiceByCustomer(customer);                  // getInvoiceByCustomer()
            if (searched && inv != null) {
                suggestServices = serviceDAO.getListService(addKeyword.trim());          // getListService()
                suggestParts = partDAO.getListPart(addKeyword.trim());                   // getListPart()
            }
        }
    } finally { customerDAO.close(); invoiceDAO.close(); serviceDAO.close(); partDAO.close(); }
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Hóa đơn</title><link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css"></head>
<body><div class="wrap">
  <div class="top noprint"><h1>Hóa đơn thanh toán</h1>
    <a href="SearchCustomerScreen0.jsp">← Tìm khách hàng khác</a></div>
<% if (msg != null && !msg.isEmpty()) { %><div class="ok" id="outMessage"><%= esc(msg) %></div><% } %>
<% if (err != null && !err.isEmpty()) { %><div class="err" id="outErrorMessage"><%= esc(err) %></div><% } %>
<% if (justPaid && inv != null) { %><div class="ok" id="outSuccess">Xác nhận hóa đơn thành công.</div><% } %>
<% if (customer == null) { %>
  <div class="err">Không tìm thấy khách hàng.</div>
<% } else { %>
  <p><b>Khách hàng:</b> <%= esc(customer.getFullName()) %> — <%= esc(customer.getPhoneNumber()) %></p>
<%   if (inv == null) { %>
  <div class="err">Khách hàng không có hóa đơn chưa thanh toán.</div>
<%   } else {
       boolean unpaid = InvoiceDAO.UNPAID.equals(inv.getStatus()); %>
  <div class="invoice" id="outInvoiceItems">
    <h2>Hóa đơn #<%= inv.getId() %> — <span class="<%= unpaid ? "st-unpaid" : "st-paid" %>"><%= esc(inv.getStatus()) %></span></h2>
    <dl>
      <dt>Ngày lập</dt><dd><%= inv.getIssueDate() == null ? "" : df.format(inv.getIssueDate()) %></dd>
      <dt>Xe</dt><dd><%= esc(inv.getVehicle().getLicensePlate()) %> (<%= esc(inv.getVehicle().getBrand()) %> <%= esc(inv.getVehicle().getModel()) %>)</dd>
      <dt>Nhân viên bán hàng</dt><dd><%= esc(inv.getSalesStaff().getFullName()) %></dd>
      <dt>Nhân viên kỹ thuật</dt><dd><%= esc(inv.getTechnicalStaff().getFullName()) %></dd>
    </dl>
    <table>
      <tr><th>Dịch vụ</th><th>Đơn giá</th></tr>
      <% for (InvoiceServiceDetail0 d : inv.getInvoiceServiceDetail()) { %>
      <tr><td><%= esc(d.getService().getName()) %></td><td><%= nf.format(d.getUnitPrice()) %> đ</td></tr>
      <% } if (inv.getInvoiceServiceDetail().isEmpty()) { %><tr><td colspan="2"><i>Chưa có dịch vụ</i></td></tr><% } %>
    </table>
    <table>
      <tr><th>Phụ tùng</th><th>SL</th><th>Đơn giá</th><th>Thành tiền</th></tr>
      <% for (InvoicePartDetail0 d : inv.getInvoicePartDetail()) { %>
      <tr><td><%= esc(d.getPart().getName()) %></td><td><%= d.getQuantity() %> <%= esc(d.getPart().getUnit()) %></td>
          <td><%= nf.format(d.getUnitPrice()) %> đ</td><td><%= nf.format((long) d.getUnitPrice() * d.getQuantity()) %> đ</td></tr>
      <% } if (inv.getInvoicePartDetail().isEmpty()) { %><tr><td colspan="4"><i>Chưa có phụ tùng</i></td></tr><% } %>
    </table>
    <p class="total">Tổng tiền: <%= nf.format(inv.getTotalAmount()) %> đ</p>
  </div>

<%     if (unpaid) { %>
  <div class="noprint">
    <h3>Bổ sung dịch vụ / phụ tùng</h3>
    <form method="get" action="InvoiceScreen0.jsp">
      <input type="hidden" name="customerId" value="<%= customerId %>">
      <label for="inAddKeyword">Từ khóa</label>
      <input type="text" id="inAddKeyword" name="inAddKeyword" value="<%= esc(addKeyword) %>" placeholder="VD: dầu">
      <button type="submit" name="subSearchToAdd">Tìm</button>
    </form>
<%       if (searched) {
           if (suggestServices.isEmpty() && suggestParts.isEmpty()) { %>
    <div class="err">Không tìm thấy dịch vụ/phụ tùng phù hợp</div>
<%         } else { %>
    <form method="post" action="InvoiceScreen0.jsp">
      <input type="hidden" name="action" value="add">
      <input type="hidden" name="customerId" value="<%= customerId %>">
      <input type="hidden" name="inAddKeyword" value="<%= esc(addKeyword) %>">
      <table id="outSuggestList">
        <tr><th>Loại</th><th>Tên</th><th>Đơn giá</th><th>Số lượng</th></tr>
        <% for (Service0 s : suggestServices) { %>
        <tr><td>Dịch vụ</td><td><%= esc(s.getName()) %></td><td><%= nf.format(s.getPrice()) %> đ</td>
            <td><input type="number" name="qtyS_<%= s.getId() %>" value="0" min="0" class="qty"></td></tr>
        <% } %>
        <% for (Part0 p : suggestParts) { %>
        <tr><td>Phụ tùng</td><td><%= esc(p.getName()) %> <small>(còn <%= p.getStockQuantity() %> <%= esc(p.getUnit()) %>)</small></td>
            <td><%= nf.format(p.getImportPrice()) %> đ</td>
            <td><input type="number" name="qtyP_<%= p.getId() %>" value="0" min="0" class="qty"></td></tr>
        <% } %>
      </table>
      <button type="submit" name="subAdd">Thêm vào hóa đơn</button>
    </form>
<%         }
         } %>
    <form method="post" action="InvoiceScreen0.jsp"
          onsubmit="return confirm('Xác nhận hóa đơn #<%= inv.getId() %> và nhận thanh toán?');">
      <input type="hidden" name="action" value="confirm">
      <input type="hidden" name="customerId" value="<%= customerId %>">
      <button type="submit" name="subConfirm">Xác nhận hóa đơn</button>
    </form>
  </div>
<%     } else { %>
  <div class="noprint">
    <button type="button" id="subPrint" onclick="window.print()">In hóa đơn</button>
    <a class="btn sec" id="subOK" href="SalesStaffScreen0.jsp">OK</a>
  </div>
<%     }
     }
   } %>
</div></body></html>
