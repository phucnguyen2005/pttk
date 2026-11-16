<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="garage.model.Member0" %>
<%
    Member0 member = (Member0) session.getAttribute("member");
    if (member == null || !"customer".equals(session.getAttribute("role"))) { response.sendRedirect("LoginScreen0.jsp"); return; }
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Trang chủ khách hàng</title><link rel="stylesheet" href="style.css"></head>
<body><div class="wrap">
  <div class="top"><h1>Xin chào, <%= member.getFullName() %></h1><a href="Logout.jsp">Đăng xuất</a></div>
  <p>Chọn chức năng:</p>
  <a class="btn" id="inSearchMenu" href="SearchScreen0.jsp">Tìm kiếm thông tin dịch vụ/phụ tùng</a>
</div></body></html>
