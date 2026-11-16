<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="garage.model.*,garage.dao.*,java.util.*,java.text.*,java.net.URLEncoder" %>
<%!
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
    static int toInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return -1; }
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("member") == null || !"sales".equals(session.getAttribute("role"))) {
        response.sendRedirect("LoginScreen0.jsp"); return;
    }
    int customerId = toInt(request.getParameter("customerId"));
    int invoiceId = toInt(request.getParameter("invoiceId"));
    String err = request.getParameter("err");

    // ---- actions (POST): add service / add part / confirm invoice ----
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        int invId = toInt(request.getParameter("invoiceId"));
        String message = null;
        boolean paid = false;
        InvoiceDAO dao = new InvoiceDAO();
        try {
            if ("addService".equals(action)) {
                message = dao.addService(invId, toInt(request.getParameter("serviceId")));
            } else if ("addPart".equals(action)) {
                message = dao.addPart(invId, toInt(request.getParameter("partId")), toInt(request.getParameter("quantity")));
            } else if ("confirm".equals(action)) {                       // subConfirm -> confirmInvoice()
                message = dao.confirmInvoice(invId);
                paid = message == null;
            }
        } finally { dao.close(); }
        String to = "InvoiceScreen0.jsp?customerId=" + customerId;
        if (paid) to += "&invoiceId=" + invId;                         // show the paid invoice (print)
        if (message != null) to += "&err=" + URLEncoder.encode(message, "UTF-8");
        response.sendRedirect(to);
        return;
    }

    // ---- load data (GET) ----
    CustomerDAO cdao = new CustomerDAO();
    InvoiceDAO idao = new InvoiceDAO();
    ServiceDAO sdao = new ServiceDAO();
    PartDAO pdao = new PartDAO();
    Customer0 customer = null;
    List<Invoice0> invoices = new ArrayList<>();
    List<Service0> allServices = new ArrayList<>();
    List<Part0> allParts = new ArrayList<>();
    try {
        customer = cdao.getCustomer(customerId);
        if (customer != null) {
            if (invoiceId > 0) {
                Invoice0 one = idao.getInvoiceDetail(invoiceId);
                if (one != null) invoices.add(one);
            } else {
                invoices = idao.getInvoicesOfCustomer(customerId, true);    // unpaid invoices
                allServices = sdao.getListService("");
                allParts = pdao.getListPart("");
            }
        }
    } finally { cdao.close(); idao.close(); sdao.close(); pdao.close(); }
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Hóa đơn</title><link rel="stylesheet" href="style.css"></head>
<body><div class="wrap">
  <div class="top noprint"><h1>Hóa đơn thanh toán</h1>
    <a href="SearchCustomerScreen0.jsp">← Tìm khách hàng khác</a></div>
<% if (err != null && !err.isEmpty()) { %><div class="err" id="outErrorMessage"><%= esc(err) %></div><% } %>
<% if (customer == null) { %>
  <div class="err">Không tìm thấy khách hàng.</div>
<% } else { %>
  <p><b>Khách hàng:</b> <%= esc(customer.getFullName()) %> — <%= esc(customer.getPhoneNumber()) %></p>
<%   if (invoices.isEmpty()) { %>
  <div class="err">Khách hàng không có hóa đơn chưa thanh toán.</div>
<%   }
     for (Invoice0 inv : invoices) {
       boolean unpaid = InvoiceDAO.UNPAID.equals(inv.getStatus()); %>
  <div class="invoice" id="outInvoice<%= inv.getId() %>">
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

<%     if (unpaid) { %>
    <div class="noprint">
      <form method="post" action="InvoiceScreen0.jsp" class="inline">
        <input type="hidden" name="action" value="addService">
        <input type="hidden" name="invoiceId" value="<%= inv.getId() %>">
        <input type="hidden" name="customerId" value="<%= customerId %>">
        <select name="serviceId">
          <% for (Service0 s : allServices) { %><option value="<%= s.getId() %>"><%= esc(s.getName()) %> — <%= nf.format(s.getPrice()) %> đ</option><% } %>
        </select>
        <button type="submit" name="subAddService">Thêm dịch vụ</button>
      </form>
      <form method="post" action="InvoiceScreen0.jsp" class="inline">
        <input type="hidden" name="action" value="addPart">
        <input type="hidden" name="invoiceId" value="<%= inv.getId() %>">
        <input type="hidden" name="customerId" value="<%= customerId %>">
        <select name="partId">
          <% for (Part0 p : allParts) { %><option value="<%= p.getId() %>"><%= esc(p.getName()) %> — <%= nf.format(p.getImportPrice()) %> đ (còn <%= p.getStockQuantity() %>)</option><% } %>
        </select>
        <input type="number" name="quantity" value="1" min="1" class="qty">
        <button type="submit" name="subAddPart">Thêm phụ tùng</button>
      </form>
      <form method="post" action="InvoiceScreen0.jsp"
            onsubmit="return confirm('Xác nhận hóa đơn #<%= inv.getId() %> và nhận thanh toán?');">
        <input type="hidden" name="action" value="confirm">
        <input type="hidden" name="invoiceId" value="<%= inv.getId() %>">
        <input type="hidden" name="customerId" value="<%= customerId %>">
        <button type="submit" name="subConfirm">Xác nhận hóa đơn</button>
      </form>
    </div>
<%     } else { %>
    <div class="noprint">
      <button type="button" id="subPrint" onclick="window.print()">In hóa đơn</button>
      <a class="btn sec" href="InvoiceScreen0.jsp?customerId=<%= customerId %>">Hóa đơn khác</a>
    </div>
<%     } %>
  </div>
<%   }
   } %>
</div></body></html>
