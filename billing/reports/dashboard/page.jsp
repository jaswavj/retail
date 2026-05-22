<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="op1" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
///////////////////  Sales  /////////////////
double thisSale =op1.getThisMonthPhSale();
double lastSale =op1.getLastMonthPhSale();
double saleMargin =thisSale-lastSale;
double saleMarginPercent = 0;
if (lastSale != 0) {
    saleMarginPercent = (saleMargin / lastSale) * 100;
}
String saleColor = (saleMarginPercent >= 0) ? "green" : "red";
//////////////////  Purchase  /////////////////
double thisPurchase =op1.getThisMonthPhPurchase();
double lastPurchase =op1.getLastMonthPhPurchase();
double purchaseMargin =thisPurchase-lastPurchase;
double purchaseMarginPercent = 0;
if (lastPurchase != 0) {
    purchaseMarginPercent = (purchaseMargin / lastPurchase) * 100;
}
String PurchaseColor = (purchaseMarginPercent >= 0) ? "green" : "red";

///////////////////  Today's Sales  /////////////////
double todaySales = op1.getTodaySales();
int todayBillCount = op1.getTodayBillCount();

///////////////////  Profit  /////////////////
// Calculate this month's date range
java.util.Calendar cal = java.util.Calendar.getInstance();
cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
String thisMonthStart = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
cal.set(java.util.Calendar.DAY_OF_MONTH, cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
String thisMonthEnd = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());

// Calculate last month's date range
cal.add(java.util.Calendar.MONTH, -1);
cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
String lastMonthStart = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
cal.set(java.util.Calendar.DAY_OF_MONTH, cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
String lastMonthEnd = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());

// Get profit data for this month
Vector thisMonthProfitData = op1.getProfitAnalysisReport(thisMonthStart, thisMonthEnd);
double thisProfit = 0.0;
for (int i = 0; i < thisMonthProfitData.size(); i++) {
    Vector row = (Vector) thisMonthProfitData.elementAt(i);
    double totalCost = Double.parseDouble(row.elementAt(4).toString());
    double saleTotal = Double.parseDouble(row.elementAt(5).toString());
    // Only include records where cost data is available (> 0)
    if (totalCost > 0) {
        thisProfit += (saleTotal - totalCost);
    }
}

// Get profit data for last month
Vector lastMonthProfitData = op1.getProfitAnalysisReport(lastMonthStart, lastMonthEnd);
double lastProfit = 0.0;
for (int i = 0; i < lastMonthProfitData.size(); i++) {
    Vector row = (Vector) lastMonthProfitData.elementAt(i);
    double totalCost = Double.parseDouble(row.elementAt(4).toString());
    double saleTotal = Double.parseDouble(row.elementAt(5).toString());
    // Only include records where cost data is available (> 0)
    if (totalCost > 0) {
        lastProfit += (saleTotal - totalCost);
    }
}

double profitMargin = thisProfit - lastProfit;
double profitMarginPercent = 0;
if (lastProfit != 0) {
    profitMarginPercent = (profitMargin / lastProfit) * 100;
}
String profitColor = (profitMarginPercent >= 0) ? "green" : "red";

///////////////////  Expenses  /////////////////
// Get this month's expenses
double thisExpense = 0.0;
try {
    Vector thisMonthExpenses = prod.getExpenseReport(thisMonthStart, thisMonthEnd, 0);
    if (thisMonthExpenses != null) {
        for (int i = 0; i < thisMonthExpenses.size(); i++) {
            Vector row = (Vector) thisMonthExpenses.get(i);
            if (row.size() > 4) {
                thisExpense += Double.parseDouble(row.get(4).toString());
            }
        }
    }
} catch (Exception e) {
    System.err.println("Error loading this month expenses: " + e.getMessage());
}

// Get last month's expenses
double lastExpense = 0.0;
try {
    Vector lastMonthExpenses = prod.getExpenseReport(lastMonthStart, lastMonthEnd, 0);
    if (lastMonthExpenses != null) {
        for (int i = 0; i < lastMonthExpenses.size(); i++) {
            Vector row = (Vector) lastMonthExpenses.get(i);
            if (row.size() > 4) {
                lastExpense += Double.parseDouble(row.get(4).toString());
            }
        }
    }
} catch (Exception e) {
    System.err.println("Error loading last month expenses: " + e.getMessage());
}

double expenseMargin = thisExpense - lastExpense;
double expenseMarginPercent = 0;
if (lastExpense != 0) {
    expenseMarginPercent = (expenseMargin / lastExpense) * 100;
}
String expenseColor = (expenseMarginPercent >= 0) ? "red" : "green"; // Lower expense is better

// Calculate net profit including expenses
double netProfitWithExpenses = thisProfit - thisExpense;

// Get today's date
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
String todayDate = sdf.format(new java.util.Date());

/////////////////////  Sales Graph  //////////////////
Vector vec = op1.getSalesReportCharts();  // Each element is a Vector or ArrayList
    StringBuilder labels = new StringBuilder();
    StringBuilder salesData = new StringBuilder();

    for (int i = 0; i < vec.size(); i++) {
        Vector row = (Vector) vec.elementAt(i);
        String date = row.elementAt(0).toString();   // first column is date
        String total = row.elementAt(1).toString();  // second column is total sales

        labels.append("\"").append(date).append("\"");
        if (!total.isEmpty() && !total.equals("0")) {
            salesData.append(total);
        } else {
            salesData.append("0");
        }

        if (i < vec.size() - 1) {
            labels.append(", ");
            salesData.append(", ");
        }
    }

/////////////////////  Top Customers and Suppliers Data  //////////////////
Vector<Vector> topCustomers = op1.getTopCustomers();
Vector<Vector> topSuppliers = op1.getTopSuppliers();
Vector<Vector> outstandingCustomers = op1.getOutstandingCustomers();
Vector<Vector> outstandingSuppliers = op1.getOutstandingSuppliers();

/////////////////////  Purchase Graph  //////////////////
Vector vecPurchase = op1.getPurchaseReportCharts();  // Each element is a Vector or ArrayList
    StringBuilder purchaseData = new StringBuilder();

    for (int i = 0; i < vecPurchase.size(); i++) {
        Vector row = (Vector) vecPurchase.elementAt(i);
        String total = row.elementAt(1).toString();  // second column is total purchase

        if (!total.isEmpty() && !total.equals("0")) {
            purchaseData.append(total);
        } else {
            purchaseData.append("0");
        }

        if (i < vecPurchase.size() - 1) {
            purchaseData.append(", ");
        }
    }

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Executive Dashboard</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .dashboard-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(15,27,53,0.07);
            transition: transform 0.2s, box-shadow 0.2s;
            overflow: hidden;
            background: var(--bill-card);
        }
        .dashboard-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(15,27,53,0.13);
        }
        .card-icon {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 2.5rem;
            opacity: 0.12;
        }
        .trend-up   { color: var(--bill-green); font-size: 0.9rem; font-weight: 600; }
        .trend-down { color: var(--bill-red);   font-size: 0.9rem; font-weight: 600; }
        .chart-container {
            background: var(--bill-card);
            border-radius: 12px;
            padding: 18px 20px;
            border: 1px solid var(--bill-border);
            box-shadow: 0 2px 8px rgba(15,27,53,0.05);
            height: 100%;
        }
        .chart-container h5 { color: var(--bill-navy); font-size: 0.92rem; margin-bottom: 0; }
        .chart-wrapper    { position: relative; height: 260px; width: 100%; }
        .chart-wrapper-sm { position: relative; height: 200px; width: 100%; }
        .dash-badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:0.78rem; font-weight:600; color:#fff; background: var(--bill-navy); }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Dashboard");
    request.setAttribute("pageSubtitle", "Business Overview — This Month");
    request.setAttribute("pageIcon",     "fa-solid fa-gauge-high");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page">
        <!-- Summary Cards -->
        <div class="row g-4 mb-4">
            <!-- Today's Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-danger">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-1" style="font-size: 0.7rem;">Today's Sales</h6>
                        <p class="text-muted mb-2" style="font-size: 0.65rem; margin-top: -2px;">(<%= todayDate %>)</p>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", todaySales) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="text-muted" style="font-size: 0.7rem;"><i class="fas fa-receipt me-1"></i> <%= todayBillCount %> Bills</span>
                        </div>
                        <i class="fas fa-calendar-day card-icon text-danger" style="font-size: 2.5rem;"></i>
                    </div>
                </div>
            </div>
            
            <!-- Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-primary">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Total Sales (This Month)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisSale) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= saleMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= saleMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(saleMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fa-solid fa-chart-line card-icon" style="color: var(--bill-gold);"></i>
                    </div>
                </div>
            </div>

            <!-- Purchase Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-success">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Total Purchase (This Month)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisPurchase) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= purchaseMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= purchaseMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(purchaseMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fa-solid fa-cart-shopping card-icon" style="color: var(--bill-green);"></i>
                    </div>
                </div>
            </div>

            <!-- Net Margin Card (Calculated) -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-info">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Net Difference</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisSale - thisPurchase) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="text-muted" style="font-size: 0.65rem;">Sales - Purchase</span>
                        </div>
                        <i class="fa-solid fa-wallet card-icon" style="color: var(--bill-navy);"></i>
                    </div>
                </div>
            </div>
            
             <!-- Last Month Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-warning">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Last Month Sales</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", lastSale) %></h4>
                        <div class="d-flex align-items-center">
                             <span class="text-muted" style="font-size: 0.65rem;">Previous Period</span>
                        </div>
                        <i class="fa-solid fa-clock-rotate-left card-icon" style="color: var(--bill-gold);"></i>
                    </div>
                </div>
            </div>
            
            <!-- Profit Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-success">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Gross Profit (This Month)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisProfit) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= profitMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= profitMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(profitMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fa-solid fa-chart-pie card-icon" style="color: var(--bill-green);"></i>
                    </div>
                </div>
            </div>
            
            <!-- Expenses Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4" style="border-color: var(--bill-navy) !important;">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Expenses (This Month)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisExpense) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= expenseMarginPercent < 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= expenseMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(expenseMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fas fa-receipt card-icon" style="color: var(--bill-navy);"></i>
                    </div>
                </div>
            </div>
            
            <!-- Net Profit Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 <%= netProfitWithExpenses >= 0 ? "border-success" : "border-danger" %>">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Net Profit (This Month)</h6>
                        <h4 class="fw-bold mb-2" style="font-size: 1.1rem; color: <%= netProfitWithExpenses >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>;">&#8377; <%= String.format("%,.2f", netProfitWithExpenses) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="text-muted" style="font-size: 0.65rem;">After Expenses</span>
                        </div>
                        <i class="fa-solid fa-coins card-icon" style="color: <%= netProfitWithExpenses >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>;"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Section -->
        <div class="row g-4">
            <!-- Main Combined Chart -->
            <div class="col-lg-8">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Financial Overview <small class="text-muted fw-normal" style="font-size:0.8rem;">(Last 16 Days)</small></h5>
                        <span class="dash-badge"><i class="fa-solid fa-calendar-days me-1"></i>Daily</span>
                    </div>
                    <div class="chart-wrapper">
                        <canvas id="combinedChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Distribution / Pie Chart (Placeholder or derived data) -->
            <!-- Since we don't have category data here, let's use the Purchase vs Sales comparison bar chart -->
            <div class="col-lg-4">
                <div class="chart-container">
                    <h5 class="fw-bold mb-3">Sales vs Purchase <small class="text-muted">(This Month)</small></h5>
                    <div class="chart-wrapper">
                        <canvas id="comparisonChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Detailed Graphs Row -->
        <div class="row g-4 mt-1">
             <div class="col-md-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Sales Trend</h5>
                        <button id="downloadMargin" class="bb bb-outline" style="padding:3px 12px;font-size:0.8rem;"><i class="fa-solid fa-download"></i> Save</button>
                    </div>
                    <div class="chart-wrapper-sm">
                        <canvas id="marginChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Purchase Trend</h5>
                        <button id="downloadPurchase" class="bb bb-outline" style="padding:3px 12px;font-size:0.8rem;"><i class="fa-solid fa-download"></i> Save</button>
                    </div>
                    <div class="chart-wrapper-sm">
                        <canvas id="purchaseChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Customer & Supplier Dashboards -->
        <div class="row g-4 mt-1">
            <!-- Top Customers by Sales -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-users me-2" style="color:var(--bill-navy);"></i>Top Customers (This Month)</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Customer Name</th>
                                    <th class="text-end">Total Sales</th>
                                    <th class="text-center">Bills</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (topCustomers.size() == 0) { %>
                                    <tr><td colspan="4" class="text-center text-muted">No data available</td></tr>
                                <% } else {
                                    for (int i = 0; i < topCustomers.size(); i++) {
                                        Vector row = topCustomers.get(i);
                                        String name = (String) row.get(0);
                                        double sales = (Double) row.get(1);
                                        int billCount = (Integer) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        <td class="text-end fw-bold" style="color:var(--bill-navy);">&#8377; <%= String.format("%,.2f", sales) %></td>
                                        <td class="text-center"><span class="dash-badge"><%= billCount %></span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Top Suppliers by Purchase -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-truck me-2" style="color:var(--bill-green);"></i>Top Suppliers (This Month)</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Supplier Name</th>
                                    <th class="text-end">Total Purchase</th>
                                    <th class="text-center">Orders</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (topSuppliers.size() == 0) { %>
                                    <tr><td colspan="4" class="text-center text-muted">No data available</td></tr>
                                <% } else {
                                    for (int i = 0; i < topSuppliers.size(); i++) {
                                        Vector row = topSuppliers.get(i);
                                        String name = (String) row.get(0);
                                        double purchase = (Double) row.get(1);
                                        int orderCount = (Integer) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        <td class="text-end fw-bold" style="color:var(--bill-green);">&#8377; <%= String.format("%,.2f", purchase) %></td>
                                        <td class="text-center"><span class="dash-badge"><%= orderCount %></span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Outstanding Balances -->
        <div class="row g-4 mt-1">
            <!-- Outstanding Customer Balances -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-money-bill-wave me-2" style="color:var(--bill-gold);"></i>Top Outstanding Customers</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Customer Name</th>
                                    <th class="text-end">Outstanding Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (outstandingCustomers.size() == 0) { %>
                                    <tr><td colspan="3" class="text-center text-muted">No outstanding balances</td></tr>
                                <% } else {
                                    for (int i = 0; i < outstandingCustomers.size(); i++) {
                                        Vector row = outstandingCustomers.get(i);
                                        String name = (String) row.get(0);
                                        double outstanding = (Double) row.get(1);
                                        double pending = (Double) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        
                                        <td class="text-end fw-bold" style="color:var(--bill-gold);">&#8377; <%= String.format("%,.2f", pending) %></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                            <% if (outstandingCustomers.size() > 0) {
                                double totalOutstanding = 0;
                                for (Vector row : outstandingCustomers) {
                                    totalOutstanding += (Double) row.get(1);
                                }
                            %>
                            <tfoot>
                                <tr style="background:var(--bill-bg); font-weight:700;">
                                    <th colspan="2" class="text-end">Total (Top 5):</th>
                                    <th class="text-end" style="color:var(--bill-red);">&#8377; <%= String.format("%,.2f", totalOutstanding) %></th>
                                </tr>
                            </tfoot>
                            <% } %>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Outstanding Supplier Balances -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-file-invoice-dollar me-2" style="color:var(--bill-red);"></i>Top Outstanding Suppliers</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Supplier Name</th>
                                    <th class="text-end">Outstanding Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (outstandingSuppliers.size() == 0) { %>
                                    <tr><td colspan="3" class="text-center text-muted">No outstanding balances</td></tr>
                                <% } else {
                                    for (int i = 0; i < outstandingSuppliers.size(); i++) {
                                        Vector row = outstandingSuppliers.get(i);
                                        String name = (String) row.get(0);
                                        double outstanding = (Double) row.get(1);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        <td class="text-end fw-bold" style="color:var(--bill-red);">&#8377; <%= String.format("%,.2f", outstanding) %></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                            <% if (outstandingSuppliers.size() > 0) {
                                double totalOutstanding = 0;
                                for (Vector row : outstandingSuppliers) {
                                    totalOutstanding += (Double) row.get(1);
                                }
                            %>
                            <tfoot>
                                <tr style="background:var(--bill-bg); font-weight:700;">
                                    <th colspan="2" class="text-end">Total (Top 5):</th>
                                    <th class="text-end" style="color:var(--bill-red);">&#8377; <%= String.format("%,.2f", totalOutstanding) %></th>
                                </tr>
                            </tfoot>
                            <% } %>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script>
        // Data from Server
        const labels = [<%= labels.toString() %>];
        const salesData = [<%= salesData.toString() %>];
        const purchaseData = [<%= purchaseData.toString() %>];

        // Common Chart Options
        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top',
                    labels: { color: '#0f172a', font: { size: 12, weight: '600' }, boxWidth: 12, padding: 16 }
                },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    backgroundColor: 'rgba(15,27,53,0.92)',
                    titleColor: '#c9a227',
                    bodyColor: '#e2e8f0',
                    padding: 12,
                    cornerRadius: 8,
                    callbacks: {
                        label: function(ctx) {
                            return ' ₹' + parseFloat(ctx.parsed.y).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: 'rgba(209,217,230,0.5)', drawBorder: false },
                    ticks: { color: '#64748b', callback: function(v) { return '₹' + v.toLocaleString('en-IN'); } }
                },
                x: {
                    grid: { display: false },
                    ticks: { color: '#64748b' }
                }
            },
            interaction: { mode: 'nearest', axis: 'x', intersect: false }
        };

        // 1. Combined Chart (Line for Sales, Bar for Purchase)
        new Chart(document.getElementById('combinedChart'), {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Sales',
                        data: salesData,
                        borderColor: '#c9a227',
                        backgroundColor: 'rgba(201,162,39,0.12)',
                        borderWidth: 2.5,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 3,
                        pointBackgroundColor: '#c9a227',
                        pointHoverRadius: 6
                    },
                    {
                        label: 'Purchase',
                        data: purchaseData,
                        borderColor: '#1a2540',
                        backgroundColor: 'rgba(26,37,64,0.07)',
                        borderWidth: 2,
                        borderDash: [5, 5],
                        fill: false,
                        tension: 0.4,
                        pointRadius: 3,
                        pointBackgroundColor: '#1a2540',
                        pointHoverRadius: 6
                    }
                ]
            },
            options: commonOptions
        });

        // 2. Comparison Chart (Doughnut - Total Sales vs Total Purchase)
        // Using the monthly totals (same as cards) for consistency
        const totalSalesMonth = <%= thisSale %>;
        const totalPurchaseMonth = <%= thisPurchase %>;

        new Chart(document.getElementById('comparisonChart'), {
            type: 'doughnut',
            data: {
                labels: ['Total Sales', 'Total Purchase'],
                datasets: [{
                    data: [totalSalesMonth, totalPurchaseMonth],
                    backgroundColor: ['#c9a227', '#1a2540'],
                    borderColor: ['#c9a227', '#1a2540'],
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { color: '#0f172a', font: { size: 12 }, padding: 14 } },
                    tooltip: {
                        backgroundColor: 'rgba(15,27,53,0.92)',
                        titleColor: '#c9a227',
                        bodyColor: '#e2e8f0',
                        callbacks: {
                            label: function(context) {
                                return ' ₹' + context.parsed.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
                            }
                        }
                    }
                },
                cutout: '68%'
            }
        });

        // 3. Detailed Sales Chart
        const marginChart = new Chart(document.getElementById('marginChart'), {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Sales Collection',
                    data: salesData,
                    backgroundColor: 'rgba(201,162,39,0.85)',
                    borderColor: '#c9a227',
                    borderWidth: 1,
                    borderRadius: 6,
                    barPercentage: 0.65
                }]
            },
            options: commonOptions
        });

        // 4. Detailed Purchase Chart
        const purchaseChart = new Chart(document.getElementById('purchaseChart'), {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Purchase Expenses',
                    data: purchaseData,
                    backgroundColor: 'rgba(26,37,64,0.82)',
                    borderColor: '#1a2540',
                    borderWidth: 1,
                    borderRadius: 6,
                    barPercentage: 0.65
                }]
            },
            options: commonOptions
        });

        // Download Handlers
        document.getElementById('downloadMargin').addEventListener('click', function() {
            const link = document.createElement('a');
            link.download = 'sales_chart.png';
            link.href = marginChart.toBase64Image();
            link.click();
        });

        document.getElementById('downloadPurchase').addEventListener('click', function() {
            const link = document.createElement('a');
            link.download = 'purchase_chart.png';
            link.href = purchaseChart.toBase64Image();
            link.click();
        });
    </script>
</body>
</html>
