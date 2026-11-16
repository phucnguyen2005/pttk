<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="garage.model.Member0, garage.dao.MemberDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    String error = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {          // subLogin
        String username = request.getParameter("inUsername");
        String password = request.getParameter("inPassword");
        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            error = "Vui lòng nhập tên đăng nhập và mật khẩu.";
        } else {
            MemberDAO dao = new MemberDAO();
            try {
                Member0 member = dao.checkLogin(username.trim(), password);          // checkLogin()
                if (member == null) {
                    error = "Sai tên đăng nhập hoặc mật khẩu.";                       // exception 7.1
                } else {
                    String role = dao.getRole(member.getId());
                    String home = null;
                    if ("customer".equals(role)) home = "CustomerHomeScreen0.jsp";
                    else if ("sales".equals(role)) home = "SalesStaffScreen0.jsp";
                    if (home == null) {
                        error = "Tài khoản này chưa có giao diện trong hệ thống.";
                    } else {
                        session.setAttribute("member", member);
                        session.setAttribute("role", role);
                        response.sendRedirect(home);
                        return;
                    }
                }
            } finally {
                dao.close();
            }
        }
    }
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Đăng nhập</title><link rel="stylesheet" href="style.css"></head>
<body><div class="wrap">
  <h1>Hệ thống quản lý ga-ra — Đăng nhập</h1>
  <form method="post" action="LoginScreen0.jsp">
    <label for="inUsername">Tên đăng nhập</label>
    <input type="text" id="inUsername" name="inUsername" autofocus>
    <label for="inPassword">Mật khẩu</label>
    <input type="password" id="inPassword" name="inPassword">
    <button type="submit" name="subLogin">Đăng nhập</button>
  </form>
  <% if (error != null) { %><div class="err" id="outErrorMessage"><%= error %></div><% } %>
</div></body></html>
