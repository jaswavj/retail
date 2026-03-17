<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />

<%
String unitName = request.getParameter("unitName");

try {
    if (unitName != null && !unitName.trim().isEmpty()) {
        prod.addUnit(unitName.trim());
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Unit added successfully&type=success");
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Unit name cannot be empty&type=danger");
    }
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Error: " + e.getMessage() + "&type=danger");
}
%>
