<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="garage.model.*,garage.dao.*,java.util.*, java.text.NumberFormat" %>
<%!
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("member") == null) { response.sendRedirect("LoginScreen0.jsp"); return; }

    String type = request.getParameter("type");
    String keyword = request.getParameter("inKeyword");
    int id;
    try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { id = -1; }

    Service0 service = null; Part0 part = null;
    if ("service".equals(type)) {
        ServiceDAO dao = new ServiceDAO();
        try { service = dao.getServiceDetail(id); } finally { dao.close(); }   // getServiceDetail()
    } else if ("part".equals(type)) {
        PartDAO dao = new PartDAO();
        try { part = dao.getPartDetail(id); } finally { dao.close(); }         // getPartDetail()
    }
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
    String back = "SearchScreen0.jsp" + (keyword != null ? "?inKeyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "");
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Chi tiết</title><link rel="stylesheet" href="style.css"></head>
<body><div class="wrap">
  <h1>Thông tin chi tiết</h1>
  <div id="outDetail">
  <% if (service != null) { %>
    <dl>
      <dt>Loại</dt><dd>Dịch vụ</dd>
      <dt>Tên dịch vụ</dt><dd><%= esc(service.getName()) %></dd>
      <dt>Mô tả (gồm thời gian ước tính)</dt><dd><%= esc(service.getDescription()) %></dd>
      <dt>Giá tiền</dt><dd><%= nf.format(service.getPrice()) %> đ</dd>
    </dl>
  <% } else if (part != null) { %>
    <dl>
      <dt>Loại</dt><dd>Phụ tùng</dd>
      <dt>Tên phụ tùng</dt><dd><%= esc(part.getName()) %></dd>
      <dt>Mô tả</dt><dd><%= esc(part.getDescription()) %></dd>
      <dt>Đơn vị</dt><dd><%= esc(part.getUnit()) %></dd>
      <dt>Tồn kho</dt><dd><%= part.getStockQuantity() %></dd>
      <dt>Đơn giá</dt><dd><%= nf.format(part.getImportPrice()) %> đ</dd>
    </dl>
  <% } else { %>
    <div class="err">Không tìm thấy thông tin.</div>
  <% } %>
  </div>
  <a class="btn sec" id="subBack" href="<%= back %>">Quay lại</a>
</div></body></html>
