<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*,dao.*,java.util.*, java.text.NumberFormat" %>
<%!
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");
    if (session.getAttribute("member") == null) { response.sendRedirect(request.getContextPath() + "/view/member/LoginScreen0.jsp"); return; }

    String keyword = request.getParameter("inKeyword");
    List<Service0> listService = new ArrayList<>();
    List<Part0> listPart = new ArrayList<>();
    boolean searched = keyword != null;                       // subSearch pressed (or coming back from detail)
    if (searched) {
        keyword = keyword.trim();
        ServiceDAO serviceDAO = new ServiceDAO();
        PartDAO partDAO = new PartDAO();
        try {
            listService = serviceDAO.getListService(keyword);  // getListService()
            listPart = partDAO.getListPart(keyword);           // getListPart()
        } finally {
            serviceDAO.close();
            partDAO.close();
        }
    }
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
    String kwEnc = keyword == null ? "" : java.net.URLEncoder.encode(keyword, "UTF-8");
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Tìm kiếm dịch vụ/phụ tùng</title><link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css"></head>
<body><div class="wrap">
  <div class="top"><h1>Tìm kiếm dịch vụ / phụ tùng</h1><a href="CustomerHomeScreen0.jsp">← Trang chủ</a></div>
  <form method="get" action="SearchScreen0.jsp">
    <label for="inKeyword">Từ khóa</label>
    <input type="text" id="inKeyword" name="inKeyword" value="<%= esc(keyword) %>" placeholder="VD: thay dầu" autofocus>
    <button type="submit" name="subSearch">Tìm kiếm</button>
  </form>

<% if (searched) {
     if (listService.isEmpty() && listPart.isEmpty()) { %>
  <div class="err">Không tìm thấy kết quả phù hợp</div>
<%   } else { %>
  <table id="outResultList">
    <tr><th>Loại</th><th>Tên</th><th>Giá</th></tr>
    <% for (Service0 s : listService) { %>
    <tr><td>Dịch vụ</td>
        <td><a href="DetailScreen0.jsp?type=service&id=<%= s.getId() %>&inKeyword=<%= kwEnc %>"><%= esc(s.getName()) %></a></td>
        <td><%= nf.format(s.getPrice()) %> đ</td></tr>
    <% } %>
    <% for (Part0 p : listPart) { %>
    <tr><td>Phụ tùng</td>
        <td><a href="DetailScreen0.jsp?type=part&id=<%= p.getId() %>&inKeyword=<%= kwEnc %>"><%= esc(p.getName()) %></a></td>
        <td><%= nf.format(p.getImportPrice()) %> đ</td></tr>
    <% } %>
  </table>
<%   }
   } %>
</div></body></html>
