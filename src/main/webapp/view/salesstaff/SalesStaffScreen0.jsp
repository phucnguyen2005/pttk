<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Member0" %>
<%
    Member0 member = (Member0) session.getAttribute("member");
    if (member == null || !"sales".equals(session.getAttribute("role"))) { response.sendRedirect(request.getContextPath() + "/view/member/LoginScreen0.jsp"); return; }
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Trang chủ nhân viên bán hàng</title><link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css"></head>
<body><div class="wrap">
  <div class="top"><h1>Xin chào, <%= member.getFullName() %> (nhân viên bán hàng)</h1><a href="<%= request.getContextPath() %>/view/member/Logout.jsp">Đăng xuất</a></div>
  <p>Chọn chức năng:</p>
  <a class="btn" id="subPayment" href="SearchCustomerScreen0.jsp">Thanh toán</a>
</div></body></html>
