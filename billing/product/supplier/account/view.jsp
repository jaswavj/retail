<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill"  class="billing.billingBean" />
<jsp:useBean id="prod"  class="product.productBean" />
<%
String supplierIdStr = request.getParameter("supplierId");
if (supplierIdStr == null || supplierIdStr.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/product/supplier/account/index.jsp");
    return;
}
int supplierId = Integer.parseInt(supplierIdStr);

Vector supInfo = prod.getSupplierById(supplierId);
String supName  = supInfo != null && supInfo.size() > 0 ? supInfo.get(0).toString() : "Unknown";
String supPhone = supInfo != null && supInfo.size() > 1 ? supInfo.get(1).toString() : "-";

Vector purchaseList = bill.getPurchasesBySupplierId(supplierId);

Vector account = bill.getSupplierAccount(supplierId);
double accAdvance = 0, accBalance = 0;
if (account != null && account.size() >= 4) {
    try { accAdvance = Double.parseDouble(account.get(2).toString()); } catch(Exception e){}
    try { accBalance = Double.parseDouble(account.get(3).toString()); } catch(Exception e){}
}

Vector duePayments = bill.getSupplierDuePayments(supplierId);
Vector returnList    = bill.getPurchaseReturnsBySupplierId(supplierId);

String[] _modeL = {"", "Cash", "Bank", "Mixed"};
String[] _typeL = {"-", "UPI", "Debit Card", "Credit Card", "Net Banking", "Wallet"};
java.util.ArrayList timeline = new java.util.ArrayList();
for (int i = 0; i < purchaseList.size(); i++) {
    Vector r = (Vector) purchaseList.get(i);
    double pd = 0; try { pd = Double.parseDouble(r.get(4).toString()); } catch(Exception ex){}
    String prNo = r.get(8).toString();
    String invNo = r.get(0).toString();
    String docNo = (!invNo.isEmpty() ? invNo + "/" : "") + prNo;
    Vector e = new Vector();
    e.addElement("PURCHASE");
    e.addElement(docNo);
    e.addElement(r.get(2).toString());
    e.addElement(r.get(3).toString());
    e.addElement(r.get(4).toString());
    e.addElement("");
    e.addElement("");
    e.addElement("");
    e.addElement(r.get(5).toString());
    e.addElement(r.get(6) != null ? r.get(6).toString() : "");
    e.addElement(r.get(7).toString());
    e.addElement(r.get(9).toString());
    e.addElement(String.valueOf(pd));
    e.addElement("");
    timeline.add(e);
}
for (int i = 0; i < returnList.size(); i++) {
    Vector r = (Vector) returnList.get(i);
    String returnNo = r.get(0).toString();
    String prNo     = r.get(1).toString();
    String docNo    = returnNo + " / " + prNo;
    Vector e = new Vector();
    e.addElement("RETURN");
    e.addElement(docNo);
    e.addElement(r.get(2).toString());
    e.addElement("");
    e.addElement("");
    e.addElement("");
    e.addElement("");
    e.addElement("");
    e.addElement(r.get(4).toString());
    e.addElement(r.get(5) != null ? r.get(5).toString() : "");
    e.addElement(r.get(6).toString());
    e.addElement(r.get(7).toString());
    e.addElement("0");
    e.addElement(r.get(3) != null ? r.get(3).toString() : "");
    timeline.add(e);
}
if (duePayments != null) {
    for (int i = 0; i < duePayments.size(); i++) {
        Vector dr = (Vector) duePayments.get(i);
        int dM = 0; try { dM = Integer.parseInt(dr.get(5).toString()); } catch(Exception ex){}
        int dT = 0; try { dT = Integer.parseInt(dr.get(6).toString()); } catch(Exception ex){}
        String txnType = dr.size() > 11 && dr.get(11) != null ? dr.get(11).toString().trim().toUpperCase() : "COLLECTION";
        if (txnType.isEmpty()) txnType = "COLLECTION";
        Vector e = new Vector();
        double dCashD = 0, dBankD = 0, dAmt = 0, dBal = 0;
        try { dAmt = Double.parseDouble(dr.get(1).toString()); } catch(Exception ex){}
        try { dCashD = Double.parseDouble(dr.get(2).toString()); } catch(Exception ex){}
        try { dBankD = Double.parseDouble(dr.get(3).toString()); } catch(Exception ex){}
        try { dBal = Double.parseDouble(dr.get(4).toString()); } catch(Exception ex){}
        e.addElement(txnType);
        e.addElement("");
        if ("OLD_DUE".equals(txnType)) {
            e.addElement(String.format("%.1f", dAmt));
            e.addElement("");
            e.addElement(String.format("%.1f", dBal));
        } else if ("ADVANCE".equals(txnType)) {
            e.addElement(String.format("%.1f", dAmt));
            e.addElement(String.format("%.1f", dCashD + dBankD));
            e.addElement(String.format("%.1f", dBal));
        } else {
            e.addElement(dr.get(1).toString());
            e.addElement(String.format("%.1f", dCashD + dBankD));
            e.addElement(dr.get(4).toString());
        }
        e.addElement("");
        e.addElement((dM >= 1 && dM <= 3) ? _modeL[dM] : "-");
        e.addElement((dT >= 0 && dT <= 5) ? _typeL[dT] : "-");
        e.addElement(dr.get(8).toString());
        e.addElement(dr.get(9).toString());
        e.addElement(dr.get(10).toString());
        e.addElement("-1");
        e.addElement("0");
        e.addElement(dr.size() > 12 && dr.get(12) != null ? dr.get(12).toString() : "");
        timeline.add(e);
    }
}
java.util.Collections.sort(timeline, new java.util.Comparator() {
    public int compare(Object a, Object b) {
        Vector va = (Vector) a; Vector vb = (Vector) b;
        String dtA = va.get(8).toString() + " " + va.get(9).toString();
        String dtB = vb.get(8).toString() + " " + vb.get(9).toString();
        return dtB.compareTo(dtA);
    }
});
boolean canPayDue = accBalance > 0.005;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier Balance — <%=supName%></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .bill-row-link { cursor:pointer; }
        .bill-row-link:hover td { background: var(--table-hover, #f1f5f9) !important; }
        .bill-row-link.selected td { background: #eff6ff !important; border-left: 3px solid #3b82f6; }
        #rightPanel { position:sticky; top:80px; }
        .pay-label { font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.5px; display:block; margin-bottom:3px; }
        .pay-inp   { height:34px; border:1.5px solid #d1d9e6; border-radius:6px; padding:0 9px; font-size:13px; width:100%; outline:none; }
        .pay-sel   { height:34px; border:1.5px solid #d1d9e6; border-radius:6px; padding:0 7px; font-size:13px; width:100%; outline:none; }
        .pay-inp:focus, .pay-sel:focus { border-color:#6366f1; box-shadow:0 0 0 3px rgba(99,102,241,.15); }
        @media (max-width:768px) {
            .left-col, .right-col { width:100% !important; }
        }
    </style>
</head>
<body>
<jsp:include page="/assets/navbar/navbar.jsp" />
<%
    request.setAttribute("pageTitle",    supName);
    request.setAttribute("pageSubtitle", "Supplier Account — " + supPhone);
    request.setAttribute("pageIcon",     "fa-solid fa-truck-field");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid px-3 pt-2 mst-page" style="max-width:100%;">
  <a href="<%=contextPath%>/product/supplier/account/index.jsp" class="bb bb-outline" style="font-size:12px;height:30px;padding:0 12px;display:inline-flex;align-items:center;gap:6px;">
    <i class="fa-solid fa-arrow-left"></i> Back
  </a>
</div>

<div class="container-fluid mt-2 mst-page">

  <div class="d-flex gap-3 align-items-start" style="flex-wrap:wrap;">

    <div class="left-col" style="flex:3;min-width:0;">

      <div class="row g-3 mb-3">
        <div class="col-4">
          <div class="mst-card p-3 text-center">
            <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Total Purchases</div>
            <div style="font-size:26px;font-weight:900;"><%=purchaseList.size()%></div>
          </div>
        </div>
        <div class="col-4">
          <div class="mst-card p-3 text-center">
            <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Advance</div>
            <div style="font-size:22px;font-weight:900;color:#16a34a;">&#8377;<%= String.format("%,.2f", accAdvance)%></div>
          </div>
        </div>
        <div class="col-4">
          <div class="mst-card p-3 text-center">
            <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Account Balance</div>
            <div style="font-size:22px;font-weight:900;color:<%=accBalance > 0 ? "#dc2626" : "#16a34a"%>;">&#8377;<%= String.format("%,.2f", accBalance)%></div>
          </div>
        </div>
      </div>

      <div class="mst-card">
        <div class="mst-card-header px-3 py-2 d-flex align-items-center justify-content-between">
          <span style="font-weight:700;font-size:13px;"><i class="fa-solid fa-receipt me-2"></i>Transactions</span>
        </div>
        <div class="table-responsive">
          <table class="table mst-table mb-0" style="font-size:12.5px;">
            <thead>
              <tr>
                <th>#</th>
                <th>Type</th>
                <th>GRN No</th>
                <th class="text-end">Payable / Amt</th>
                <th class="text-end">Paid</th>
                <th class="text-end">Pending</th>
                <th>Date / Time</th>
                <th>User</th>
              </tr>
            </thead>
            <tbody>
              <% if (timeline.isEmpty()) { %>
              <tr><td colspan="8" class="text-center py-4 text-muted">No transactions found.</td></tr>
              <%
              } else {
                for (int i = 0; i < timeline.size(); i++) {
                  Vector te      = (Vector) timeline.get(i);
                  boolean isPurchase = "PURCHASE".equals(te.get(0).toString());
                  boolean isReturn   = "RETURN".equals(te.get(0).toString());
                  String txnType = isPurchase ? "PURCHASE" : te.get(0).toString();
                  String teNotes = te.size() > 13 && te.get(13) != null ? te.get(13).toString() : "";
                  String teDocNo = te.get(1).toString();
                  String teCol1  = te.get(2).toString();
                  String teCol2  = te.get(3).toString();
                  String teCol3  = te.get(4).toString();
                  String teDate  = te.get(8).toString();
                  String teTime  = te.get(9).toString();
                  String teUser  = te.get(10).toString();
                  String tePurId = te.get(11).toString();
                  double tePendD = 0; try { tePendD = Double.parseDouble(te.get(12).toString()); } catch(Exception ex){}
                  double teCol3D = 0; try { teCol3D = Double.parseDouble(teCol3.isEmpty() ? "0" : teCol3); } catch(Exception ex){}
                  boolean hasPend = isPurchase && tePendD > 0;
                  boolean isOldDue = "OLD_DUE".equals(txnType);
                  boolean isAdvance = "ADVANCE".equals(txnType);
                  String rowBg   = isPurchase ? (hasPend ? "background:#fff1f1;" : "") : (isReturn ? "background:#faf5ff;" : (isOldDue ? "background:#fff7ed;" : (isAdvance ? "background:#eff6ff;" : "background:#f0fdf4;")));
                  String tdBg    = isPurchase ? (hasPend ? "background:#fff1f1 !important;" : "") : (isReturn ? "background:#f3e8ff !important;" : (isOldDue ? "background:#ffedd5 !important;" : (isAdvance ? "background:#dbeafe !important;" : "background:#ecfdf5 !important;")));
              %>
              <tr <%=isPurchase ? "class=\"bill-row-link\" data-purchase-id=\""+tePurId+"\" onclick=\"selectPurchase(this,"+tePurId+")\"" : ""%>
                  style="<%=rowBg%>">
                <td style="<%=tdBg%>"><%=i+1%></td>
                <td style="<%=tdBg%>">
                  <% if (isPurchase) { %>
                  <span class="badge" style="font-size:10px;font-weight:700;background:<%=hasPend ? "#fee2e2;color:#b91c1c" : "#dbeafe;color:#1d4ed8"%>;">PURCHASE</span>
                  <% } else if (isReturn) { %>
                  <span class="badge" style="font-size:10px;font-weight:700;background:#f3e8ff;color:#7e22ce;">RETURN</span>
                  <% } else if (isOldDue) { %>
                  <span class="badge" style="font-size:10px;font-weight:700;background:#ffedd5;color:#c2410c;">OLD DUE</span>
                  <% } else if (isAdvance) { %>
                  <span class="badge" style="font-size:10px;font-weight:700;background:#dbeafe;color:#1d4ed8;">ADVANCE</span>
                  <% } else { %>
                  <span class="badge" style="font-size:10px;font-weight:700;background:#dcfce7;color:#15803d;">PAYMENT</span>
                  <% } %>
                </td>
                <td style="<%=tdBg%>">
                  <% if (isPurchase || isReturn) { %><span style="font-weight:600;"><%=teDocNo%></span>
                  <% } else if (!teNotes.isEmpty()) { %><span style="font-size:11px;"><%=teNotes%></span>
                  <% } else { %><span style="opacity:.35;">—</span><% } %>
                </td>
                <td class="text-end" style="<%=tdBg%>"><%=teCol1.isEmpty() ? "<span style='opacity:.3'>—</span>" : teCol1%></td>
                <td class="text-end" style="<%=tdBg%>"><%=teCol2.isEmpty() ? "<span style='opacity:.3'>—</span>" : teCol2%></td>
                <td class="text-end <%=isPurchase ? (hasPend ? "text-danger fw-bold" : "text-success") : (isOldDue ? "text-danger fw-bold" : (teCol3D > 0 ? "text-danger fw-bold" : "text-success"))%>" style="<%=tdBg%>">
                  <%=teCol3.isEmpty() ? "<span style='opacity:.3'>—</span>" : teCol3%>
                </td>
                <td style="white-space:nowrap;<%=tdBg%>"><%=teDate%>
                  <% if (!teTime.isEmpty()) { %><br><span style="font-size:10px;opacity:.6;"><%=teTime%></span><% } %>
                </td>
                <td style="<%=tdBg%>"><%=teUser%></td>
              </tr>
              <% } } %>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div class="right-col" id="rightPanel" style="flex:2;min-width:280px;">

      <div class="mst-card">
        <div class="mst-card-header px-3 py-2">
          <span style="font-weight:700;font-size:13px;"><i class="fa-solid fa-circle-dollar-to-slot me-2"></i>Account Entry</span>
        </div>
        <div class="p-3">
          <div class="mb-2">
            <label class="pay-label">Entry Type</label>
            <select id="entryType" class="pay-sel" onchange="onEntryTypeChange()">
              <option value="COLLECTION" <%= canPayDue ? "selected" : "disabled" %>>Pay Supplier (Due)</option>
              <option value="ADVANCE" <%= !canPayDue ? "selected" : "" %>>Add Advance</option>
              <option value="OLD_DUE">Add Old Due (Before System)</option>
            </select>
          </div>
          <div id="noDueHint" class="small mb-2" style="display:<%= canPayDue ? "none" : "block" %>;color:#b45309;">
            <i class="fa-solid fa-circle-info me-1"></i>No account balance due. You cannot pay until there is a due balance.
          </div>

          <div class="mb-2">
            <label class="pay-label" id="amountLabel">Amount to Pay</label>
            <input type="number" id="collectAmount" class="pay-inp" placeholder="0.00" min="0" step="0.01"
                   value="<%= String.format("%.2f", Math.max(0, accBalance))%>"
                   oninput="onAmountChange()"
                   style="height:52px;font-size:20px;font-weight:800;background:#f0fdf4;border-color:#86efac;color:#15803d;">
          </div>

          <div class="mb-2" id="payModeBlock">
            <label class="pay-label">Pay Mode</label>
            <select id="payMode" class="pay-sel" onchange="onModeChange()">
              <option value="1">Cash</option>
              <option value="2">Bank</option>
              <option value="3">Mixed</option>
            </select>
          </div>

          <div class="mb-2" id="payTypeRow">
            <label class="pay-label">Pay Type</label>
            <select id="payType" class="pay-sel">
              <option value="1">UPI</option>
              <option value="2">Debit Card</option>
              <option value="3">Credit Card</option>
              <option value="4">Net Banking</option>
              <option value="5">Wallet</option>
            </select>
          </div>

          <div class="mb-2" id="cashRow">
            <label class="pay-label">Cash Paid</label>
            <input type="number" id="cashPaid" class="pay-inp" placeholder="0.00" min="0" step="0.01" oninput="onCashChange()">
          </div>

          <div class="mb-2" id="bankRow" style="display:none;">
            <label class="pay-label">Bank Paid</label>
            <input type="number" id="bankPaid" class="pay-inp" placeholder="0.00" min="0" step="0.01" oninput="onBankChange()">
          </div>

          <div class="mb-2">
            <label class="pay-label">Notes <span style="font-weight:400;text-transform:none;">(optional)</span></label>
            <input type="text" id="entryNotes" class="pay-inp" placeholder="Remark or reference">
          </div>

          <div class="mb-3" id="remainingBlock">
            <label class="pay-label">Remaining Balance</label>
            <input type="number" id="remainingBalance" class="pay-inp" placeholder="0.00" readonly
                   style="background:#f8fafc;font-weight:700;color:#dc2626;">
          </div>

          <button class="bb bb-primary w-100" onclick="submitPayment()" id="submitBtn" style="height:38px;font-size:13px;">
            <i class="fa-solid fa-check me-1"></i> <span id="submitBtnLabel">Submit Payment</span>
          </button>
          <div id="payError" style="display:none;color:#dc2626;font-size:12px;margin-top:6px;text-align:center;"></div>
        </div>
      </div>

    </div>
  </div>
</div>

<div class="modal fade" id="purchaseDetailModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header mst-card-header">
        <h5 class="modal-title">Purchase Details</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" id="modalPurchaseContent">
        <div class="text-center text-muted py-5">Select a purchase row to view details.</div>
      </div>
      <div class="modal-footer">
        <button class="bb bb-outline" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script>
const contextPath = '<%=contextPath%>';
const supplierId  = <%=supplierId%>;
const accBalance  = <%=accBalance%>;
const accAdvance  = <%=accAdvance%>;
const canPayDue   = <%=canPayDue%>;

function selectPurchase(row, purchaseId) {
    document.querySelectorAll('.bill-row-link').forEach(r => r.classList.remove('selected'));
    row.classList.add('selected');
    window.open(contextPath + '/product/purchase/report/purchaseRegister/purchaseDetails.jsp?id=' + purchaseId, '_blank');
}

const netPayable = Math.max(0, accBalance);

function onEntryTypeChange() {
    const entryType = document.getElementById('entryType').value;
    const amountInp = document.getElementById('collectAmount');
    const amountLabel = document.getElementById('amountLabel');
    const submitLabel = document.getElementById('submitBtnLabel');
    const payModeBlock = document.getElementById('payModeBlock');
    const payTypeRow = document.getElementById('payTypeRow');
    const cashRow = document.getElementById('cashRow');
    const bankRow = document.getElementById('bankRow');
    const remainingBlock = document.getElementById('remainingBlock');
    const notesInp = document.getElementById('entryNotes');

    if (entryType === 'OLD_DUE') {
        amountLabel.textContent = 'Old Due Amount';
        submitLabel.textContent = 'Save Old Due';
        amountInp.value = '';
        amountInp.style.background = '#fff7ed';
        amountInp.style.borderColor = '#fdba74';
        amountInp.style.color = '#c2410c';
        payModeBlock.style.display = 'none';
        payTypeRow.style.display = 'none';
        cashRow.style.display = 'none';
        bankRow.style.display = 'none';
        remainingBlock.style.display = 'none';
        if (!notesInp.value) notesInp.placeholder = 'e.g. Opening balance before go-live';
    } else if (entryType === 'ADVANCE') {
        amountLabel.textContent = 'Advance Amount';
        submitLabel.textContent = 'Save Advance';
        amountInp.value = '';
        amountInp.style.background = '#eff6ff';
        amountInp.style.borderColor = '#93c5fd';
        amountInp.style.color = '#1d4ed8';
        payModeBlock.style.display = '';
        remainingBlock.style.display = 'none';
        if (!notesInp.value) notesInp.placeholder = 'e.g. Advance for future purchases';
        onModeChange();
    } else {
        amountLabel.textContent = 'Amount to Pay';
        submitLabel.textContent = 'Submit Payment';
        amountInp.value = netPayable.toFixed(2);
        amountInp.style.background = '#f0fdf4';
        amountInp.style.borderColor = '#86efac';
        amountInp.style.color = '#15803d';
        payModeBlock.style.display = '';
        remainingBlock.style.display = '';
        notesInp.placeholder = 'Remark or reference';
        if (!canPayDue) {
            document.getElementById('entryType').value = 'ADVANCE';
            onEntryTypeChange();
            return;
        }
        onModeChange();
    }
    updateCollectionSubmitState();
}

function updateCollectionSubmitState() {
    const entryType = document.getElementById('entryType').value;
    const btn = document.getElementById('submitBtn');
    const errBox = document.getElementById('payError');
    if (entryType === 'COLLECTION' && !canPayDue) {
        btn.disabled = true;
        errBox.textContent = 'No account balance due to pay.';
        errBox.style.display = 'block';
    } else if (entryType === 'COLLECTION' || entryType === 'ADVANCE' || entryType === 'OLD_DUE') {
        btn.disabled = false;
        if (errBox.textContent === 'No account balance due to pay.') {
            errBox.style.display = 'none';
            errBox.textContent = '';
        }
    }
}

function onModeChange() {
    if (document.getElementById('entryType').value === 'OLD_DUE') return;
    const mode = document.getElementById('payMode').value;
    const total = parseFloat(document.getElementById('collectAmount').value) || 0;

    document.getElementById('cashRow').style.display  = (mode === '1' || mode === '3') ? '' : 'none';
    document.getElementById('bankRow').style.display  = (mode === '2' || mode === '3') ? '' : 'none';
    document.getElementById('payTypeRow').style.display = (mode === '2' || mode === '3') ? '' : 'none';

    if (mode === '1') {
        document.getElementById('cashPaid').value = total.toFixed(2);
        document.getElementById('bankPaid').value = '';
    } else if (mode === '2') {
        document.getElementById('bankPaid').value = total.toFixed(2);
        document.getElementById('cashPaid').value = '';
    } else {
        document.getElementById('cashPaid').value = total.toFixed(2);
        document.getElementById('bankPaid').value = '0.00';
    }
    calcRemaining();
}

function onAmountChange() { onModeChange(); }

function onCashChange() {
    const mode  = document.getElementById('payMode').value;
    const total = parseFloat(document.getElementById('collectAmount').value) || 0;
    const cash  = parseFloat(document.getElementById('cashPaid').value) || 0;
    if (mode === '3') {
        document.getElementById('bankPaid').value = Math.max(0, total - cash).toFixed(2);
    }
    calcRemaining();
}

function onBankChange() {
    const mode  = document.getElementById('payMode').value;
    const total = parseFloat(document.getElementById('collectAmount').value) || 0;
    const bank  = parseFloat(document.getElementById('bankPaid').value) || 0;
    if (mode === '3') {
        document.getElementById('cashPaid').value = Math.max(0, total - bank).toFixed(2);
    }
    calcRemaining();
}

function calcRemaining() {
    if (document.getElementById('entryType').value !== 'COLLECTION') return;
    const total = parseFloat(document.getElementById('collectAmount').value) || 0;
    const cash  = parseFloat(document.getElementById('cashPaid').value)  || 0;
    const bank  = parseFloat(document.getElementById('bankPaid').value)  || 0;
    const mode  = document.getElementById('payMode').value;
    let paid = mode === '1' ? cash : mode === '2' ? bank : (cash + bank);
    document.getElementById('remainingBalance').value = Math.max(0, accBalance - paid).toFixed(2);
}

function submitPayment() {
    const errBox = document.getElementById('payError');
    errBox.style.display = 'none';

    const entryType = document.getElementById('entryType').value;
    const amount = parseFloat(document.getElementById('collectAmount').value) || 0;
    const mode   = document.getElementById('payMode').value;
    const cash   = parseFloat(document.getElementById('cashPaid').value)  || 0;
    const bank   = parseFloat(document.getElementById('bankPaid').value)  || 0;
    const notes  = document.getElementById('entryNotes').value || '';

    if (entryType === 'COLLECTION' && !canPayDue) {
        errBox.textContent = 'No account balance due to pay.';
        errBox.style.display = 'block';
        return;
    }

    if (amount <= 0) {
        errBox.textContent = 'Please enter an amount greater than zero.';
        errBox.style.display = 'block'; return;
    }

    if (entryType !== 'OLD_DUE') {
        if (mode === '1' && cash <= 0) {
            errBox.textContent = 'Please enter cash paid amount.';
            errBox.style.display = 'block'; return;
        }
        if (mode === '2' && bank <= 0) {
            errBox.textContent = 'Please enter bank paid amount.';
            errBox.style.display = 'block'; return;
        }
        if (mode === '3') {
            if (cash <= 0 && bank <= 0) {
                errBox.textContent = 'Please enter cash and/or bank amount.';
                errBox.style.display = 'block'; return;
            }
            if (Math.abs((cash + bank) - amount) > 0.01) {
                errBox.textContent = 'Cash + Bank must equal the amount.';
                errBox.style.display = 'block'; return;
            }
        }
    }

    const btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-1"></i> Saving…';

    const params = new URLSearchParams({
        supplierId: supplierId,
        entryType:  entryType,
        amount:     amount.toFixed(2),
        cashPaid:   (entryType === 'OLD_DUE' || mode === '2') ? '0' : cash.toFixed(2),
        bankPaid:   (entryType === 'OLD_DUE' || mode === '1') ? '0' : bank.toFixed(2),
        payMode:    entryType === 'OLD_DUE' ? '1' : mode,
        payType:    document.getElementById('payType').value,
        notes:      notes
    });

    fetch(contextPath + '/product/supplier/account/saveSupplierAccountEntry.jsp', {
        method:  'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body:    params.toString()
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            let msg = data.message || 'Saved successfully.';
            if (data.entryType === 'COLLECTION' && data.newBalance != null) {
                msg = 'Remaining balance: ₹' + parseFloat(data.newBalance).toFixed(2);
            } else if (data.entryType === 'ADVANCE' && data.newAdvance != null) {
                msg = 'Total advance: ₹' + parseFloat(data.newAdvance).toFixed(2);
            } else if (data.entryType === 'OLD_DUE' && data.newBalance != null) {
                msg = 'Account balance: ₹' + parseFloat(data.newBalance).toFixed(2);
            }
            Swal.fire({
                icon: 'success',
                title: 'Saved',
                text: msg,
                confirmButtonText: 'OK'
            }).then(() => location.reload());
        } else {
            errBox.textContent = data.message || 'Error saving entry.';
            errBox.style.display = 'block';
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> <span id="submitBtnLabel">' + document.getElementById('submitBtnLabel').textContent + '</span>';
        }
    })
    .catch(() => {
        errBox.textContent = 'Network error. Please try again.';
        errBox.style.display = 'block';
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i> <span id="submitBtnLabel">' + document.getElementById('submitBtnLabel').textContent + '</span>';
    });
}

onEntryTypeChange();
</script>
</body>
</html>
