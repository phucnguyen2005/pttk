<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="garage.model.*,garage.dao.*,java.util.*" %>
<%!
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("member") == null || !"sales".equals(session.getAttribute("role"))) {
        response.sendRedirect("LoginScreen0.jsp"); return;
    }
    String name = request.getParameter("inName");
    boolean searched = name != null;
    List<Customer0> listCustomer = new ArrayList<>();
    if (searched) {
        name = name.trim();
        CustomerDAO dao = new CustomerDAO();
        try { listCustomer = dao.searchCustomer(name); } finally { dao.close(); }   // searchCustomer()
    }
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Tìm khách hàng</title><link rel="stylesheet" href="style.css"></head>
<body><div class="wrap">
  <div class="top"><h1>Thanh toán — tìm khách hàng</h1><a href="SalesStaffScreen0.jsp">← Trang chủ</a></div>
  <form method="get" action="SearchCustomerScreen0.jsp">
    <label for="inName">Tên khách hàng</label>
    <input type="text" id="inName" name="inName" value="<%= esc(name) %>" placeholder="VD: Nguyễn" autofocus>
    <button type="submit" name="subSearch">Tìm kiếm</button>
  </form>
<% if (searched) {
     if (listCustomer.isEmpty()) { %>
  <div class="err">Không tìm thấy khách hàng phù hợp</div>
<%   } else { %>
  <table id="outCustomerList">
    <tr><th>Mã</th><th>Họ tên</th><th>Điện thoại</th><th>Địa chỉ</th></tr>
    <% for (Customer0 c : listCustomer) { %>
    <tr><td><%= c.getId() %></td>
        <td><a href="InvoiceScreen0.jsp?customerId=<%= c.getId() %>"><%= esc(c.getFullName()) %></a></td>
        <td><%= esc(c.getPhoneNumber()) %></td><td><%= esc(c.getAddress()) %></td></tr>
    <% } %>
  </table>
<%   }
   } %>
</div></body></html>
