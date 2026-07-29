<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, org.json.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
response.setCharacterEncoding("UTF-8");
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
    return;
}

String rowsJson = request.getParameter("rows");
if (rowsJson == null || rowsJson.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"No data received.\"}");
    return;
}

int successCount = 0;
int failCount = 0;
JSONArray errors = new JSONArray();

try {
    JSONArray rows = new JSONArray(rowsJson);
    if (rows.length() == 0) {
        out.print("{\"success\":false,\"message\":\"The file has no product rows.\"}");
        return;
    }

    for (int i = 0; i < rows.length(); i++) {
        int rowNum = i + 2; // header is row 1
        JSONObject row = rows.getJSONObject(i);
        try {
            String categoryName = row.optString("categoryName", "").trim();
            String brandName = row.optString("brandName", "").trim();
            String productName = row.optString("productName", "").trim();
            String productCode = row.optString("productCode", "").trim();
            if (productCode.isEmpty()) productCode = "0";
            String hsn = row.optString("hsn", "").trim();
            if (hsn.isEmpty()) hsn = null;
            String unitName = row.optString("unitName", "").trim();

            if (categoryName.isEmpty() || brandName.isEmpty() || productName.isEmpty()) {
                throw new Exception("Category, Brand and Product Name are required.");
            }
            if (unitName.isEmpty()) {
                throw new Exception("Unit is required.");
            }

            int categoryId = prod.getCategoryIdByName(categoryName);
            int brandId = prod.getBrandIdByName(brandName);
            int unitId = prod.getUnitIdByName(unitName);
            if (categoryId == 0) throw new Exception("Category not found: " + categoryName);
            if (brandId == 0) throw new Exception("Brand not found: " + brandName);
            if (unitId == 0) throw new Exception("Unit not found: " + unitName);

            double cost = parseDouble(row.optString("cost", "0"), "Cost Price");
            double mrp = parseDouble(row.optString("mrp", "0"), "MRP");
            if (cost <= 0 || mrp <= 0) {
                throw new Exception("Cost Price and MRP must be greater than zero.");
            }

            BigDecimal stock = new BigDecimal(row.optString("stock", "0").trim().isEmpty() ? "0" : row.optString("stock", "0").trim());
            double commission = parseDoubleOptional(row.optString("commission", "0"));
            int discType = parseDiscType(row.optString("discType", ""));
            double discValue = parseDoubleOptional(row.optString("discValue", "0"));
            int gst = parseIntOptional(row.optString("gst", "0"));

            Vector selectedUnit = prod.getUnitById(unitId);
            if (selectedUnit != null && selectedUnit.size() > 3 && selectedUnit.elementAt(3) != null) {
                BigDecimal convertionCalculation = (BigDecimal) selectedUnit.elementAt(3);
                if (convertionCalculation.compareTo(BigDecimal.ZERO) > 0) {
                    stock = stock.multiply(convertionCalculation);
                    BigDecimal calcBD = convertionCalculation;
                    cost = new BigDecimal(cost).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
                    mrp = new BigDecimal(mrp).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
                    commission = new BigDecimal(commission).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
                }
            }

            prod.addProduct(
                productName, categoryId, brandId, productCode,
                cost, mrp, discType, discValue, stock,
                userId, gst, unitId, hsn, commission
            );
            successCount++;
        } catch (Exception ex) {
            failCount++;
            JSONObject err = new JSONObject();
            err.put("row", rowNum);
            err.put("message", ex.getMessage() != null ? ex.getMessage() : "Failed");
            errors.put(err);
        }
    }

    JSONObject result = new JSONObject();
    result.put("success", failCount == 0 || successCount > 0);
    result.put("successCount", successCount);
    result.put("failCount", failCount);
    result.put("errors", errors);
    if (successCount > 0 && failCount == 0) {
        result.put("message", successCount + " product(s) added successfully.");
    } else if (successCount > 0) {
        result.put("message", successCount + " added, " + failCount + " failed. See details below.");
    } else {
        result.put("message", "No products were added. Please check the file and try again.");
    }
    out.print(result.toString());
} catch (Exception e) {
    JSONObject err = new JSONObject();
    err.put("success", false);
    err.put("message", e.getMessage() != null ? e.getMessage() : "Invalid upload data.");
    out.print(err.toString());
}
%><%!
private static double parseDouble(String val, String label) throws Exception {
    if (val == null || val.trim().isEmpty()) {
        throw new Exception(label + " is required.");
    }
    try {
        return Double.parseDouble(val.trim());
    } catch (NumberFormatException e) {
        throw new Exception("Invalid " + label + ": " + val);
    }
}

private static double parseDoubleOptional(String val) {
    if (val == null || val.trim().isEmpty()) return 0.0;
    try { return Double.parseDouble(val.trim()); } catch (NumberFormatException e) { return 0.0; }
}

private static int parseIntOptional(String val) {
    if (val == null || val.trim().isEmpty()) return 0;
    try { return (int) Math.round(Double.parseDouble(val.trim().replace("%", ""))); } catch (NumberFormatException e) { return 0; }
}

private static int parseDiscType(String val) {
    if (val == null || val.trim().isEmpty() || val.trim().equals("0")) return 0;
    String v = val.trim().toLowerCase();
    if (v.equals("rs") || v.equals("1") || v.equals("rupee") || v.equals("rupees")) return 1;
    if (v.equals("%") || v.equals("2") || v.equals("percent") || v.equals("percentage")) return 2;
    return 0;
}
%>
