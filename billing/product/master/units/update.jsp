<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />

<%
String idStr = request.getParameter("id");
String unitName = request.getParameter("unitName");

try {
    if (idStr != null && unitName != null && !unitName.trim().isEmpty()) {
        int id = Integer.parseInt(idStr);
        prod.updateUnit(id, unitName.trim());
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Unit updated successfully&type=success");
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Invalid unit information&type=danger");
    }
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Error: " + e.getMessage() + "&type=danger");
}
%>
