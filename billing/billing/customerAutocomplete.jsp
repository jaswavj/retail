<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    request.setCharacterEncoding("UTF-8");
    String query = request.getParameter("query");
    
    JSONArray results = new JSONArray();
    
    if (query != null && !query.trim().isEmpty()) {
        try {
            Vector customers = prod.searchCustomers(query);
            
            for (int i = 0; i < customers.size(); i++) {
                Vector customer = (Vector) customers.get(i);
                
                JSONObject obj = new JSONObject();
                obj.put("id", customer.elementAt(0));
                obj.put("name", customer.elementAt(1));
                obj.put("phone", customer.elementAt(2));
                obj.put("address", customer.elementAt(3));
                obj.put("gstin", customer.elementAt(4));
                obj.put("creditLimit", customer.elementAt(5));
                obj.put("isGst", customer.elementAt(6));
                
                results.put(obj);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    out.print(results.toString());
%>
