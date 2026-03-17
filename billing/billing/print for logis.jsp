<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.text.DecimalFormat"%>

<jsp:useBean id="bill" class="billing.billingBean" />
<%
String billNo = request.getParameter("billNo");
if(billNo == null || billNo.trim().isEmpty()){
    out.print("Error: Missing bill number");
    return;
}

double extradisc = bill.getExtraDisc(billNo);
String cusName=bill.getCusName(billNo);
String cusNumber=bill.getCusNumber(billNo);

// Get customer details from customers table
Vector customerDetails = bill.getCustomerDetailsByBillNo(billNo);
String customerName = "-";
String customerPhone = "-";
String customerAddress = "-";
String customerGSTIN = "-";

if (customerDetails != null && customerDetails.size() >= 4) {
    customerName = customerDetails.get(0) != null ? customerDetails.get(0).toString() : cusName;
    customerPhone = customerDetails.get(1) != null ? customerDetails.get(1).toString() : cusNumber;
    customerAddress = customerDetails.get(2) != null ? customerDetails.get(2).toString() : "-";
    customerGSTIN = customerDetails.get(3) != null ? customerDetails.get(3).toString() : "-";
} else {
    // Fallback to old fields if customer not found
    customerName = cusName;
    customerPhone = cusNumber;
}


double paid = bill.getPaidTotal(billNo);
String numPaid=bill.getNumPaid(paid);
double balance = bill.getbalanceTotal(billNo);
String billDate = bill.getBillDate(billNo);
Vector<Vector<Object>> billDetails = bill.getBillDetailsUsingNo(billNo);

DecimalFormat df = new DecimalFormat("0.00");

// GST Calculation variables
double totalAmount = 0;
double totalDiscount = 0;
double finalPaid = 0;
double totalItemAmount = 0;
double totalTaxableAmount = 0;
double totalCGST = 0;
double totalSGST = 0;
double totalGSTAmount = 0;
double totalQty = 0;

// Map to store GST-wise totals
Map<Integer, Double> gstWiseTaxable = new HashMap<Integer, Double>();
Map<Integer, Double> gstWiseCGST = new HashMap<Integer, Double>();
Map<Integer, Double> gstWiseSGST = new HashMap<Integer, Double>();

for(Vector<Object> prod : billDetails){
    double itemTotal = Double.parseDouble(prod.get(4).toString());
    double itemDisc = Double.parseDouble(prod.get(3).toString());
    double itemPrice = Double.parseDouble(prod.get(2).toString());
    int gstPer = Integer.parseInt(prod.get(5).toString());
    double qty = Double.parseDouble(prod.get(1).toString());
    
    // Calculate taxable amount (amount before GST)
    double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
    double gstAmount = itemTotal - taxableAmount;
    double cgst = gstAmount / 2;
    double sgst = gstAmount / 2;
    
    totalAmount += itemTotal;
    totalDiscount += itemDisc;
    totalItemAmount += itemPrice;
    totalTaxableAmount += taxableAmount;
    totalCGST += cgst;
    totalSGST += sgst;
    totalGSTAmount += gstAmount;
    totalQty += qty;
    
    // Group by GST rate
    gstWiseTaxable.put(gstPer, gstWiseTaxable.getOrDefault(gstPer, 0.0) + taxableAmount);
    gstWiseCGST.put(gstPer, gstWiseCGST.getOrDefault(gstPer, 0.0) + cgst);
    gstWiseSGST.put(gstPer, gstWiseSGST.getOrDefault(gstPer, 0.0) + sgst);
}
    
finalPaid = totalAmount - extradisc;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Tax Invoice</title>
    <style>
        @page { size: A4; margin: 8mm; }
        * { box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            font-size: 13px;
            margin: 0;
            padding: 5px;
            color: #000;
            line-height: 1.4;
        }
        .container {
            width: 100%;
            border: 2px solid #000;
            margin: 0 auto;
        }
        
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .font-bold { font-weight: bold; }
        
        /* Header Section */
        .header-table {
            width: 100%;
            border-collapse: collapse;
            border-bottom: 2px solid #000;
        }
        .header-table td {
            padding: 8px 12px;
            vertical-align: top;
        }
        .header-main-title {
            font-size: 36px;
            font-weight: 900;
            color: #000;
            font-family: 'Rockwell', serif;
            text-transform: uppercase;
            margin-bottom: -15px;
        }
        .header-subtitle-row td {
            padding: 4px 12px;
            background-color: #10b981;
            color: white;
            font-size: 14px;
            font-weight: 600;
            letter-spacing: 2px;
        }
        .header-contact {
            font-size: 11px;
            line-height: 1.8;
            color: #000;
        }
        .header-logo-cell {
            width: 180px;
            text-align: center;
            vertical-align: middle;
            border-left: none;
            padding: 8px 0px;
        }
        .logo-box {
            width: 150px;
            height: 150px;
            background-color: white;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0px;
        }
        .logo-box img {
            max-width: 170px;
            max-height: 140px;
            object-fit: contain;
        }
        
        /* PAN & Invoice Title Row */
        .title-row {
            display: flex;
            border-bottom: 1px solid #000;
            align-items: center;
        }
        .pan-section {
            width: 25%;
            padding: 3px 5px;
            border-right: none;
            font-size: 15px;
        }
        .invoice-title-section {
            width: 75%;
            text-align: center;
            padding: 5px;
            font-weight: bold;
            font-size: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .invoice-title-section .center-title {
            flex: 1;
            text-align: center;
        }
        .invoice-title-section .right-text {
            font-size: 12px;
            font-weight: normal;
            white-space: nowrap;
        }
        
        /* Customer & Invoice Details */
        .details-row {
            display: flex;
            border-bottom: 1px solid #000;
            font-size: 12px;
            margin-bottom: 10px;
        }
        .customer-section {
            width: 40%;
            border-right: 1px solid #000;
        }
        .invoice-section {
            width: 60%;
        }
        .section-header {
            padding: 3px 5px;
            font-weight: bold;
            background-color: transparent;
            border-bottom: 1px solid #000;
            text-align: center;
        }
        .detail-line {
            padding: 2px 5px;
            display: flex;
        }
        .detail-line strong {
            min-width: 100px;
            display: inline-block;
        }
        
        /* Items Table */
        .items-table {
            width: 100%;
            border-collapse: collapse;
        }
        .items-table th {
            background-color: #fff;
            color: #000;
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-top: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 4px 2px;
            font-size: 12px;
            text-align: center;
            font-weight: bold;
        }
        .items-table th:first-child {
            border-left: 1px solid #000;
        }
        .items-table th:last-child {
            border-right: 1px solid #000;
        }
        .items-table td {
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-top: none;
            border-bottom: none;
            padding: 3px 4px;
            font-size: 12px;
            vertical-align: middle;
        }
        .items-table tbody tr:first-child td {
            border-top: 1px solid #000;
        }
        .items-table tbody {
            min-height: 250px;
        }
        
        /* Total Row */
        .total-row {
            font-weight: bold;
            background-color: transparent;
        }
        .total-row td {
            border-top: 1px solid #000 !important;
            border-bottom: 1px solid #000 !important;
        }
        
        /* Bottom Sections */
        .bottom-section {
            display: flex;
            border-top: 1px solid #000;
        }
        .total-words {
            width: 50%;
            border-right: 1px solid #000;
            padding: 5px;
            font-size: 12px;
        }
        .totals-right {
            width: 50%;
            font-size: 12px;
        }
        .totals-right .row-item {
            display: flex;
            justify-content: space-between;
            padding: 3px 5px;
            border-bottom: 1px solid #000;
        }
        .totals-right .row-item.final {
            font-weight: bold;
            font-size: 13px;
        }
        
        /* Bank Details & Terms */
        .footer-section {
            display: flex;
            border-top: 1px solid #000;
            min-height: 120px;
        }
        .left-footer {
            width: 50%;
            border-right: 1px solid #000;
            display: flex;
            flex-direction: column;
        }
        .bank-details {
            padding: 8px;
            font-size: 12px;
            display: flex;
            border-bottom: 1px solid #000;
        }
        .bank-info {
            flex: 1;
        }
        .bank-details strong {
            display: block;
            margin-bottom: 5px;
        }
        .bank-row {
            display: flex;
            margin-bottom: 3px;
            border-bottom: 1px solid #ddd;
            padding-bottom: 2px;
        }
        .bank-label {
            min-width: 90px;
            font-weight: normal;
        }
        .qr-code {
            width: 120px;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            margin-left: 10px;
        }
        .qr-code img {
            width: 100px;
            height: 100px;
            border: 1px solid #000;
        }
        .qr-text {
            font-size: 11px;
            margin-top: 5px;
        }
        .terms-customer {
            padding: 8px;
            font-size: 10px;
            line-height: 1.5;
        }
        .terms-section {
            width: 50%;
            padding: 15px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .certification-text {
            text-align: center;
            font-size: 10px;
            line-height: 1.5;
            margin-bottom: 10px;
        }
        .company-name {
            text-align: center;
            font-weight: bold;
            font-size: 11px;
            margin-bottom: 20px;
        }
        .signature-area {
            text-align: center;
            margin-top: auto;
        }
        .signature-text {
            font-size: 10px;
            margin-bottom: 30px;
            transform: rotate(-5deg);
            font-style: italic;
        }
        .signature-line {
            border-top: 1px solid #000;
            padding-top: 5px;
            font-size: 11px;
            text-align: center;
            margin-top: 10px;
        }
        
        /* Print/Cancel Buttons */
        .print-controls {
            position: fixed;
            top: 10px;
            right: 10px;
            z-index: 1000;
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 8px 16px;
            font-size: 12px;
            font-weight: bold;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-print {
            background-color: #4CAF50;
            color: white;
        }
        .btn-print:hover {
            background-color: #45a049;
        }
        .btn-cancel {
            background-color: #f44336;
            color: white;
        }
        .btn-cancel:hover {
            background-color: #da190b;
        }
        
        @media print {
            .print-controls {
                display: none !important;
            }
            body {
                padding: 0;
            }
        }
    </style>
    <script>
        window.onload = function() {
            // Direct print on page load
            window.print();
        };
        
        // Close window after print dialog is closed (either printed or cancelled)
        window.onafterprint = function() {
            window.close();
        };
        
        function printInvoice() {
            window.print();
        }
        
        function cancelPrint() {
            window.close();
        }
    </script>
</head>
<body>

<!-- Print/Cancel Controls -->
<div class="print-controls">
    <button class="btn btn-print" onclick="printInvoice()">🖨️ Print</button>
    <button class="btn btn-cancel" onclick="cancelPrint()">❌ Cancel</button>
</div>

<div class="container">
    <!-- Company Header Table -->
    <table class="header-table">
        <tr>
            <td>
                <div class="header-main-title">GLOBAL LOGISTICS</div>
            </td>
            <td class="header-logo-cell" rowspan="3">
                <div class="logo-box">
                    <img src="logo.jpg" alt="Logo" onerror="this.style.display='none'">
                </div>
            </td>
        </tr>
        <tr class="header-subtitle-row">
            <td>UNLEASHING THE POWER OF DELIVERY</td>
        </tr>
        <tr>
            <td class="header-contact">
                
                <div> Plot No Street Name, <span style="margin-left: 320px;"><strong>Tel:</strong> 0000000000</span>
                    <br> Village And Post Office, <span style="margin-left: 250px;"><strong>Web:</strong> www.yourWebsite.com</span>
                    <br> District and State - Pincode <span style="margin-left: 243px;"><strong>Email:</strong> info@yourmail.com</span>
                </div>
            </td>
        </tr>
    </table>

    <!-- PAN & Title Row -->
    <div class="title-row">
        <div class="pan-section">
            <strong>PAN :</strong> 26CORPP3939N1
        </div>
        <div class="invoice-title-section">
            <span class="center-title">TAX INVOICE</span>
            <span class="right-text">ORIGINAL FOR RECIPIENT</span>
        </div>
    </div>

    <!-- Customer & Invoice Details -->
    <div class="details-row">
        <div class="customer-section">
            <div class="section-header">Customer Detail</div>
            <div class="detail-line">
                <strong>M/S</strong>
                <span><%= customerName %></span>
            </div>
            <div class="detail-line">
                <strong>Address</strong>
                <span><%= customerAddress.equals("-") ? "" : customerAddress %></span>
            </div>
            <div class="detail-line">
                <strong>Phone</strong>
                <span><%= customerPhone.equals("-") ? "" : customerPhone %></span>
            </div>
            <div class="detail-line">
                <strong>GSTIN</strong>
                <span><%= customerGSTIN.equals("-") ? "" : customerGSTIN %></span>
            </div>
            
        </div>
        <div class="invoice-section">
            <div class="detail-line">
                <strong>Invoice No</strong>
                <span>GST-3425-26</span>
            </div>
            
            <div class="detail-line">
                <strong>Invoice Date</strong>
                <span>23-Jul-2025</span>
            </div>
            
            
        </div>
    </div>

    <!-- Items Table -->
    <table class="items-table">
        <thead>
            <tr>
                <th style="width: 4%;" rowspan="2">Sr.<br>No.</th>
                <th style="width: 30%;" rowspan="2">Name of Product / Service</th>
                <th style="width: 8%;" rowspan="2">HSN</th>
                <th style="width: 8%;" rowspan="2">Qty</th>
                <th style="width: 10%;" rowspan="2">Rate</th>
                <th style="width: 12%;" rowspan="2">Taxable Value</th>
                <th colspan="2" style="width: 14%;">IGST</th>
                <th style="width: 14%;" rowspan="2">Total</th>
            </tr>
            <tr>
                <th style="width: 7%;">%</th>
                <th style="width: 7%;">Amount</th>
            </tr>
        </thead>
        <tbody>
            <%
            int count = 1;
            for(Vector<Object> prod : billDetails){
                double itemTotal = Double.parseDouble(prod.get(4).toString());
                double itemPrice = Double.parseDouble(prod.get(2).toString());
                int gstPer = Integer.parseInt(prod.get(5).toString());
                double qty = Double.parseDouble(prod.get(1).toString());
                
                String productName = prod.get(0).toString();
                
                double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
                double gstAmount = itemTotal - taxableAmount;
            %>
            <tr>
                <td class="text-center"><%= count++ %></td>
                <td><%= productName %></td>
                <td class="text-center">8302</td>
                <td class="text-center"><%= qty %> NOS</td>
                <td class="text-right"><%= df.format(itemPrice) %></td>
                <td class="text-right"><%= df.format(taxableAmount) %></td>
                <td class="text-center"><%= gstPer %>.00</td>
                <td class="text-right"><%= df.format(gstAmount) %></td>
                <td class="text-right"><%= df.format(itemTotal) %></td>
            </tr>
            <% } %>
            <!-- Fill empty rows if needed -->
            <% for(int i = billDetails.size(); i < 5; i++) { %>
            <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </tr>
            <% } %>
        </tbody>
        <tfoot>
            <tr class="total-row">
                <td colspan="3" class="text-right"><strong>Total</strong></td>
                <td class="text-center"><strong><%= totalQty %> NOS</strong></td>
                <td></td>
                <td class="text-right"><strong><%= df.format(totalTaxableAmount) %></strong></td>
                <td></td>
                <td class="text-right"><strong><%= df.format(totalGSTAmount) %></strong></td>
                <td class="text-right"><strong><%= df.format(totalAmount) %></strong></td>
            </tr>
        </tfoot>
    </table>

    <!-- Total in Words & Amount Breakdown -->
    <div class="bottom-section">
        <div class="total-words">
            <strong>Total in words</strong><br>
            <div style="margin-top: 5px; text-transform: uppercase;">
                <%= numPaid %> ONLY
            </div>
        </div>
        <div class="totals-right">
            <div class="row-item">
                <span><strong>Taxable Amount</strong></span>
                <span><%= df.format(totalTaxableAmount) %></span>
            </div>
            <div class="row-item">
                <span><strong>Add : IGST</strong></span>
                <span><%= df.format(totalGSTAmount) %></span>
            </div>
            <div class="row-item">
                <span><strong>Add Tax</strong></span>
                <span><%= df.format(totalGSTAmount) %></span>
            </div>
            <div class="row-item final">
                <span><strong>Total Amount After Tax</strong></span>
                <span><strong>₹<%= df.format(finalPaid) %></strong></span>
            </div>
            <div style="text-align: right; padding: 3px 5px; font-size: 7px;">
                ( E & O E )
            </div>
            <div style="text-align: center; padding: 5px; font-size: 7px; border-top: 1px solid #000;">
                <strong>Certified that the particulars given above are true and correct.</strong><br>
                <strong>For Gujarat Freight Tools</strong>
            </div>
        </div>
    </div>

    <!-- Bank Details & Terms -->
    <div class="footer-section">
        <div class="left-footer">
            <div class="bank-details">
                <div class="bank-info">
                    <strong>Bank Details</strong>
                    <div class="bank-row">
                        <div class="bank-label">Name</div>
                        <div>ICICI</div>
                    </div>
                    <div class="bank-row">
                        <div class="bank-label">Branch</div>
                        <div>Surat</div>
                    </div>
                    <div class="bank-row">
                        <div class="bank-label">Acc. Number</div>
                        <div>2715500356</div>
                    </div>
                    <div class="bank-row">
                        <div class="bank-label">IFSC</div>
                        <div>ICIC045F</div>
                    </div>
                    <div class="bank-row">
                        <div class="bank-label">UPI ID</div>
                        <div>ifov@icici</div>
                    </div>
                </div>
                <div class="qr-code">
                    <div style="width: 100px; height: 100px; border: 1px solid #000; display: flex; align-items: center; justify-content: center; font-size: 10px;">
                        QR CODE
                    </div>
                    <div class="qr-text"><strong>Pay using UPI</strong></div>
                </div>
            </div>
            <div class="terms-customer">
                <div style="text-align: center; font-weight: bold; margin-bottom: 5px; font-size: 11px;">Terms and Conditions</div>
                <div style="border-bottom: 1px solid #000; margin-bottom: 8px;"></div>
                <div>Subject to Maharashtra Jurisdiction.</div>
                <div>Our Responsibility Ceases as soon as goods leaves our Premises.</div>
                <div>We are not responsible for any Damage in Transit.</div>
                <div>Delivery Ex-Premises.</div>
                <div style="margin-top: 20px;"><strong>Customer Signature</strong></div>
                <div style="border-bottom: 1px solid #000; margin-top: 5px;"></div>
                <div style="margin-bottom: 10px;"></div>
            </div>
        </div>
        <div class="terms-section">
            <div>
                <div class="certification-text">
                    <strong>Certified that the particulars given above are true and correct.</strong>
                </div>
                <div class="company-name">
                    For Gujarat Freight Tools
                </div>
            </div>
            <div class="signature-area">
                <div class="signature-text">
                    This is a Computer generated<br>
                    Invoice. No signature required.
                </div>
                <div class="signature-line">
                    <strong>Authorised Signatory</strong>
                </div>
            </div>
        </div>
    </div>

    <!-- Thank You Message -->
    <div style="text-align: center; padding: 5px; font-size: 8px; border-top: 2px solid #000;">
        Thank you for shopping with us!
    </div>
</div>

</body>
</html>
