<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    try {
        response.setContentType("application/json");
        
        // Get parameters
        String searchTerm = request.getParameter("search");
        if (searchTerm == null) searchTerm = "";
        
        int currentPage = 1;
        int pageSize = 20; // Number of products per page
        
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                currentPage = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
        
        try {
            String pageSizeParam = request.getParameter("pageSize");
            if (pageSizeParam != null && !pageSizeParam.isEmpty()) {
                pageSize = Integer.parseInt(pageSizeParam);
            }
        } catch (NumberFormatException e) {
            pageSize = 20;
        }
        
        JSONObject result = new JSONObject();
        JSONArray productsArray = new JSONArray();
        
        // Get all products
        Vector productList = prod.getAllProducts();
        
        if (productList != null) {
            // Filter products based on search term
            Vector filteredProducts = new Vector();
            for (int i = 0; i < productList.size(); i++) {
                Vector row = (Vector) productList.get(i);
                if (row != null && row.size() > 14) {
                    String productName = row.elementAt(0) != null ? row.elementAt(0).toString().toLowerCase() : "";
                    String prodCode = row.elementAt(1) != null ? row.elementAt(1).toString().toLowerCase() : "";
                    String categ = row.elementAt(2) != null ? row.elementAt(2).toString().toLowerCase() : "";
                    String brandss = row.elementAt(3) != null ? row.elementAt(3).toString().toLowerCase() : "";
                    
                    String searchLower = searchTerm.toLowerCase();
                    if (searchTerm.isEmpty() || 
                        productName.contains(searchLower) || 
                        prodCode.contains(searchLower) || 
                        categ.contains(searchLower) || 
                        brandss.contains(searchLower)) {
                        filteredProducts.add(row);
                    }
                }
            }
            
            int totalProducts = filteredProducts.size();
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            
            // Calculate pagination boundaries
            int startIndex = (currentPage - 1) * pageSize;
            int endIndex = Math.min(startIndex + pageSize, totalProducts);
            
            // Get paginated products
            for (int i = startIndex; i < endIndex; i++) {
                Vector row = (Vector) filteredProducts.get(i);
                
                JSONObject productObj = new JSONObject();
                productObj.put("index", i + 1);
                productObj.put("productName", row.elementAt(0) != null ? row.elementAt(0).toString() : "");
                productObj.put("prodCode", row.elementAt(1) != null ? row.elementAt(1).toString() : "");
                productObj.put("productId", Integer.parseInt(row.elementAt(8).toString()));
                productObj.put("categ", row.elementAt(2) != null ? row.elementAt(2).toString() : "");
                productObj.put("brandss", row.elementAt(3) != null ? row.elementAt(3).toString() : "");
                productObj.put("mrp", Double.parseDouble(row.elementAt(4).toString()));
                productObj.put("cost", Double.parseDouble(row.elementAt(9).toString()));
                productObj.put("discType", Integer.parseInt(row.elementAt(10).toString()));
                productObj.put("discount", Double.parseDouble(row.elementAt(11).toString()));
                productObj.put("gst", Integer.parseInt(row.elementAt(12).toString()));
                productObj.put("unitId", row.elementAt(13) != null ? row.elementAt(13).toString() : "");
                productObj.put("hsn", row.elementAt(14) != null ? row.elementAt(14).toString() : "");
                productObj.put("stock", row.elementAt(6) != null ? row.elementAt(6).toString() : "0");
                
                // Get unit name
                String unitName = "";
                if (row.size() > 15 && row.elementAt(15) != null) {
                    unitName = row.elementAt(15).toString();
                } else if (row.elementAt(13) != null) {
                    // Fallback: try to get unit name from unitId
                    String unitId = row.elementAt(13).toString();
                    Vector units = prod.getUnits();
                    if (units != null) {
                        for (int j = 0; j < units.size(); j++) {
                            Vector unit = (Vector) units.get(j);
                            if (unit != null && unit.elementAt(1) != null && unit.elementAt(1).toString().equals(unitId)) {
                                unitName = unit.elementAt(0) != null ? unit.elementAt(0).toString() : "";
                                break;
                            }
                        }
                    }
                }
                productObj.put("unit", unitName);
                
                productsArray.put(productObj);
            }
            
            result.put("products", productsArray);
            result.put("totalProducts", totalProducts);
            result.put("totalPages", totalPages);
            result.put("currentPage", currentPage);
            result.put("pageSize", pageSize);
            result.put("success", true);
        } else {
            result.put("products", productsArray);
            result.put("totalProducts", 0);
            result.put("totalPages", 0);
            result.put("currentPage", 1);
            result.put("pageSize", pageSize);
            result.put("success", true);
        }
        
        out.print(result.toString());
        
    } catch (Exception e) {
        response.setContentType("application/json");
        JSONObject errorResult = new JSONObject();
        errorResult.put("success", false);
        errorResult.put("error", e.getMessage());
        errorResult.put("products", new JSONArray());
        errorResult.put("totalProducts", 0);
        errorResult.put("totalPages", 0);
        errorResult.put("currentPage", 1);
        errorResult.put("pageSize", 20);
        out.print(errorResult.toString());
    }
%>
