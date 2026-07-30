<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    request.setCharacterEncoding("UTF-8");
    String query = request.getParameter("query");
    String phone = request.getParameter("phone");

    JSONArray results = new JSONArray();

    try {
        Vector suppliers;
        if (phone != null && !phone.trim().isEmpty()) {
            suppliers = prod.searchSuppliers(phone.trim());
        } else if (query != null && !query.trim().isEmpty()) {
            suppliers = prod.searchSuppliers(query.trim());
        } else {
            out.print(results.toString());
            return;
        }

        for (int i = 0; i < suppliers.size(); i++) {
            Vector supplier = (Vector) suppliers.get(i);

            JSONObject obj = new JSONObject();
            obj.put("id", supplier.elementAt(0));
            obj.put("name", supplier.elementAt(1));
            obj.put("phone", supplier.elementAt(2));
            obj.put("address", supplier.elementAt(3));
            obj.put("gstin", supplier.elementAt(4));

            results.put(obj);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    out.print(results.toString());
%>
