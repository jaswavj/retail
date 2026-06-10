<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill"  class="billing.billingBean" />
<jsp:useBean id="prod"  class="product.productBean" />
<%
// contextPath declared by head.jsp include
String customerIdStr = request.getParameter("customerId");
if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/billing/customer/index.jsp");
    return;
}
int customerId = Integer.parseInt(customerIdStr);

// Customer info
Vector custInfo = prod.getCustomerById(customerId);
String custName  = custInfo != null && custInfo.size() > 0 ? custInfo.get(0).toString() : "Unknown";
String custPhone = custInfo != null && custInfo.size() > 1 ? custInfo.get(1).toString() : "-";

// Bills
Vector billList = bill.getBillsByCustomerId(customerId);

// Account
Vector account = bill.getCustomerAccount(customerId);
double accAdvance = 0, accBalance = 0;
if (account != null && account.size() >= 4) {
    try { accAdvance = Double.parseDouble(account.get(2).toString()); } catch(Exception e){}
    try { accBalance = Double.parseDouble(account.get(3).toString()); } catch(Exception e){}
}

// Total pending from bills
double totalPending = 0;
for (int i = 0; i < billList.size(); i++) {
    Vector r = (Vector) billList.get(i);
    try { double cb = Double.parseDouble(r.get(10).toString()); if (cb > 0) totalPending += cb; } catch(Exception e){}
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Balance — <%=custName%></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .bill-row-link { cursor:pointer; }
        .bill-row-link:hover td { background: var(--table-hover, #f1f5f9) !important; }
        .bill-row-link.selected td { background: #eff6ff !important; border-left: 3px solid #3b82f6; }
        #rightPanel { position:sticky; top:80px; }

        /* Payment fields */
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
    request.setAttribute("pageTitle",    custName);
    request.setAttribute("pageSubtitle", "Customer Account — " + custPhone);
    request.setAttribute("pageIcon",     "fa-solid fa-user-circle");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

  <!-- Main 2-column layout -->
  <div class="d-flex gap-3 align-items-start" style="flex-wrap:wrap;">

    <!-- LEFT: Stats + Bills table (60%) -->
    <div class="left-col" style="flex:3;min-width:0;">

      <!-- Stat cards above bills table -->
      <div class="row g-3 mb-3">
        <div class="col-3">
          <div class="mst-card p-3 text-center">
            <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Total Bills</div>
            <div style="font-size:26px;font-weight:900;"><%=billList.size()%></div>
          </div>
        </div>
        <div class="col-3">
          <div class="mst-card p-3 text-center">
            <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Pending Due</div>
            <div style="font-size:22px;font-weight:900;color:#dc2626;">&#8377;<%= String.format("%,.2f", totalPending)%></div>
          </div>
        </div>
        <div class="col-3">
          <div class="mst-card p-3 text-center">
            <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Advance</div>
            <div style="font-size:22px;font-weight:900;color:#16a34a;">&#8377;<%= String.format("%,.2f", accAdvance)%></div>
          </div>
        </div>
        <div class="col-3">
          <div class="mst-card p-3 text-center">
            <div style="font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.8px;opacity:.7;">Account Balance</div>
            <div style="font-size:22px;font-weight:900;color:<%=accBalance > 0 ? "#dc2626" : "#16a34a"%>;">&#8377;<%= String.format("%,.2f", accBalance)%></div>
          </div>
        </div>
      </div>

      <div class="mst-card">
        <div class="mst-card-header px-3 py-2 d-flex align-items-center justify-content-between">
          <span style="font-weight:700;font-size:13px;"><i class="fa-solid fa-file-invoice me-2"></i>All Bills</span>
          <a href="<%=contextPath%>/billing/customer/index.jsp" class="bb bb-outline" style="font-size:11px;height:28px;padding:0 10px;">
            <i class="fa-solid fa-arrow-left me-1"></i>Back
          </a>
        </div>
        <div class="table-responsive">
          <table class="table mst-table mb-0" style="font-size:12.5px;">
            <thead>
              <tr>
                <th>#</th>
                <th>Bill No</th>
                <th class="text-end">Payable</th>
                <th class="text-end">Paid</th>
                <th class="text-end">Pending</th>
                <th>Date</th>
                <th>Biller</th>
              </tr>
            </thead>
            <tbody id="billTableBody">
              <% if (billList.isEmpty()) { %>
              <tr><td colspan="7" class="text-center py-4 text-muted">No bills found for this customer.</td></tr>
              <%
              } else {
                for (int i = 0; i < billList.size(); i++) {
                  Vector row = (Vector) billList.get(i);
                  String payable  = row.get(2).toString();
                  String paid     = row.get(3).toString();
                  String curBal   = row.get(10).toString();
                  String date     = row.get(5).toString();
                  String biller   = row.get(7).toString();
                  String billNo   = row.get(8).toString();
                  int    billId   = Integer.parseInt(row.get(9).toString());
                  double curBalD  = 0;
                  try { curBalD = Double.parseDouble(curBal); } catch(Exception e){}
              %>
              <tr class="bill-row-link" data-bill-id="<%=billId%>" onclick="selectBill(this, <%=billId%>)">
                <td><%=i+1%></td>
                <td><span style="font-weight:600;"><%=billNo%></span></td>
                <td class="text-end"><%=payable%></td>
                <td class="text-end"><%=paid%></td>
                <td class="text-end <%=curBalD > 0 ? "text-danger fw-bold" : "text-success"%>"><%=curBal%></td>
                <td><%=date%></td>
                <td><%=biller%></td>
              </tr>
              <% }} %>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- RIGHT: Account info + payment (40%) -->
    <div class="right-col" id="rightPanel" style="flex:2;min-width:280px;">

      <!-- Bill detail placeholder -->
      <div class="mst-card mb-3" id="billDetailBox" style="display:none;">
        <div class="mst-card-header px-3 py-2">
          <span style="font-weight:700;font-size:13px;"><i class="fa-solid fa-receipt me-2"></i>Bill Detail</span>
        </div>
        <div class="p-3" id="billDetailContent">
          <div class="text-center text-muted py-3"><i class="fa-solid fa-spinner fa-spin"></i> Loading…</div>
        </div>
      </div>

      <!-- Payment Box -->
      <div class="mst-card">
        <div class="mst-card-header px-3 py-2">
          <span style="font-weight:700;font-size:13px;"><i class="fa-solid fa-circle-dollar-to-slot me-2"></i>Collect Payment</span>
        </div>
        <div class="p-3">
          <div class="mb-2">
            <label class="pay-label">Amount to Collect</label>
            <input type="number" id="collectAmount" class="pay-inp" placeholder="0.00" min="0" step="0.01"
                   value="<%= String.format("%.2f", Math.max(0, accBalance - accAdvance))%>"
                   oninput="onAmountChange()"
                   style="height:52px;font-size:20px;font-weight:800;background:#f0fdf4;border-color:#86efac;color:#15803d;">
          </div>

          <div class="mb-2">
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

          <div class="mb-3">
            <label class="pay-label">Remaining Balance</label>
            <input type="number" id="remainingBalance" class="pay-inp" placeholder="0.00" readonly
                   style="background:#f8fafc;font-weight:700;color:#dc2626;">
          </div>

          <button class="bb bb-primary w-100" onclick="submitPayment()" id="submitBtn" style="height:38px;font-size:13px;">
            <i class="fa-solid fa-check me-1"></i> Submit Payment
          </button>
          <div id="payError" style="display:none;color:#dc2626;font-size:12px;margin-top:6px;text-align:center;"></div>
        </div>
      </div>

    </div>
  </div>
</div>

<!-- Bill Detail Modal (for mobile or overflow) -->
<div class="modal fade" id="billDetailModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header mst-card-header">
        <h5 class="modal-title">Bill Details</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" id="modalBillContent"></div>
      <div class="modal-footer">
        <button class="bb bb-outline" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script>
const contextPath = '<%=contextPath%>';
const customerId  = <%=customerId%>;
const accBalance  = <%=accBalance%>;
const accAdvance  = <%=accAdvance%>;

// ── Bill row selection ──────────────────────────────────────
function selectBill(row, billId) {
    document.querySelectorAll('.bill-row-link').forEach(r => r.classList.remove('selected'));
    row.classList.add('selected');

    const modalContent = document.getElementById('modalBillContent');
    modalContent.innerHTML =
        '<div class="text-center text-muted py-5"><i class="fa-solid fa-spinner fa-spin fa-2x"></i><p class="mt-2">Loading…</p></div>';

    const modal = new bootstrap.Modal(document.getElementById('billDetailModal'));
    modal.show();

    fetch(contextPath + '/billing/balanceDetailModal.jsp?billId=' + billId)
        .then(r => r.text())
        .then(html => { modalContent.innerHTML = html; })
        .catch(() => { modalContent.innerHTML = '<p class="text-danger p-3">Error loading bill details.</p>'; });
}

// ── Payment logic (mirrors billing.jsp) ────────────────────
const netPayable = Math.max(0, accBalance - accAdvance);

function onModeChange() {
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

function onAmountChange() {
    onModeChange();
}

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
    const total = parseFloat(document.getElementById('collectAmount').value) || 0;
    const cash  = parseFloat(document.getElementById('cashPaid').value)  || 0;
    const bank  = parseFloat(document.getElementById('bankPaid').value)  || 0;
    const mode  = document.getElementById('payMode').value;
    let paid = mode === '1' ? cash : mode === '2' ? bank : (cash + bank);
    document.getElementById('remainingBalance').value = Math.max(0, accBalance - accAdvance - paid).toFixed(2);
}

function submitPayment() {
    const errBox = document.getElementById('payError');
    errBox.style.display = 'none';

    const amount = parseFloat(document.getElementById('collectAmount').value) || 0;
    const mode   = document.getElementById('payMode').value;
    const cash   = parseFloat(document.getElementById('cashPaid').value)  || 0;
    const bank   = parseFloat(document.getElementById('bankPaid').value)  || 0;

    // Validation
    if (amount <= 0) {
        errBox.textContent = 'Please enter an amount to collect.';
        errBox.style.display = 'block'; return;
    }
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
            errBox.textContent = 'Cash + Bank must equal the collect amount.';
            errBox.style.display = 'block'; return;
        }
    }

    // TODO: backend submit will be wired later
    Swal.fire({ icon:'info', title:'Ready to Submit', text:'Payment: ₹' + amount.toFixed(2) + ' | Mode: ' + ['','Cash','Bank','Mixed'][mode], confirmButtonText:'OK' });
}

// Init
onModeChange();
</script>
</body>
</html>
