<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body {
            background: #f5f7fa;
        }
        .navbar {
            background-color: #4e73df;
        }
        .navbar-brand {
            color: #fff !important;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        .btn-edit, .btn-delete {
            margin: 0 2px;
        }

    </style>
    
</head>
<body onload="document.form.opregInput.focus();">

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->
<%
String msg  = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>


    <div class="container mt-4 ">
        <h3>Supplier Details</h3>
        
        <!-- Add Category Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form id="supplierForm" action="<%=contextPath%>/product/master/supplier/page1.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" id="supplierId" value="0">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="supName" id="supName" class="form-control" placeholder="" required><label >Supplier Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="number" name="supPhn" id="supPhn" class="form-control" placeholder="" ><label >Phone Number</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <textarea name="supDesc" id="supDesc" placeholder="Address"></textarea>
                    </div>
                    <div class="col-md-6">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="isGst" name="isGst" onchange="toggleGstin()">
                            <label class="form-check-label" for="isGst">
                                GST Registered
                            </label>
                        </div>
                        <div class="input-outline">
                            <input type="text" name="gstin" id="gstin" class="form-control" placeholder="" maxlength="15" disabled><label>GSTIN <span class="text-danger" id="gstinRequired" style="display:none;">*</span></label>
                            <small id="gstinError" class="text-danger" style="display:none;">GSTIN must be exactly 15 characters</small>
                        </div>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" id="submitBtn" class="btn btn-primary">Add Supplier</button>
                        <button type="button" id="cancelBtn" class="btn btn-secondary" onclick="resetForm()" style="display:none;">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Product List Table -->
        
        <div class="card">
            <div class="card-body">
                <h5>Supplier List</h5>
                
                <div class="table-responsive">
                <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; min-width: 700px; table-layout: fixed;">
                    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                        <tr>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 5%;">#</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 8%;">Action</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 20%;">Name</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 12%;">Phone Number</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 12%;">GST Status</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 18%;">GSTIN</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 25%;">Description</th>
                        </tr>
                    </thead>
                    <tbody>

                        <%
                            
                            Vector vec = prod.getSupplierDetails();
                            for (int i = 0; i < vec.size(); i++) {
                                Vector vec1 = (Vector) vec.get(i); // inner vector (row)
                                String Name =vec1.elementAt(0).toString();
                                int id			= Integer.parseInt(vec1.elementAt(1).toString());
                                String desc =vec1.elementAt(2).toString();
                                String phn =vec1.elementAt(3).toString();
                                String gstin =vec1.elementAt(4).toString();
                                int isGst = Integer.parseInt(vec1.elementAt(5).toString());


                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 5%;"><%=i+1%></td>
                            <td style="padding: 0.4rem; border: none; font-size: 0.9rem; width: 8%;">
                                <button class="btn btn-sm edit-supplier-btn" style="background: var(--primary-gradient); color: white; border: none;" title="Edit"
                                    data-id="<%=id%>" 
                                    data-name="<%=Name%>" 
                                    data-phone="<%=phn%>" 
                                    data-gstin="<%=gstin%>"
                                    data-isgst="<%=isGst%>"
                                    data-desc="<%=desc%>">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 20%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=Name%>"><%=Name%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 12%;"><%=vec1.elementAt(3)%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 12%;">
                                <% if (isGst == 1) { %>
                                    <span class="badge bg-success">Registered</span>
                                <% } else { %>
                                    <span class="badge bg-secondary">Not Registered</span>
                                <% } %>
                            </td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 18%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=gstin%>"><%=gstin%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 25%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=desc%>"><%=vec1.elementAt(2)%></td>
                        </tr>
                        <%
                    }
                        %>
                        <%-- Dynamic rows will come here --%>
                    </tbody>
                </div>
                </table>
            </div>
        </div>
    </div>
</div>
    <!-- Bootstrap JS -->
<script>
  // Toggle GSTIN field based on GST checkbox
  function toggleGstin() {
    var isGstChecked = document.getElementById('isGst').checked;
    var gstinField = document.getElementById('gstin');
    var gstinRequired = document.getElementById('gstinRequired');
    var gstinError = document.getElementById('gstinError');
    
    if (isGstChecked) {
      gstinField.disabled = false;
      gstinField.required = true;
      gstinRequired.style.display = 'inline';
      gstinField.focus();
    } else {
      gstinField.disabled = true;
      gstinField.required = false;
      gstinField.value = '';
      gstinRequired.style.display = 'none';
      gstinError.style.display = 'none';
      gstinField.style.borderColor = '';
    }
  }
  
  // Real-time GSTIN validation
  document.addEventListener('DOMContentLoaded', function() {
    var gstinField = document.getElementById('gstin');
    var gstinError = document.getElementById('gstinError');
    var isGstCheckbox = document.getElementById('isGst');
    var form = document.querySelector('form');
    
    // Real-time validation on input
    gstinField.addEventListener('input', function() {
      if (isGstCheckbox.checked) {
        var length = this.value.length;
        if (length > 0 && length !== 15) {
          this.style.borderColor = '#dc3545';
          gstinError.style.display = 'block';
        } else if (length === 15) {
          this.style.borderColor = '#28a745';
          gstinError.style.display = 'none';
        } else {
          this.style.borderColor = '';
          gstinError.style.display = 'none';
        }
      }
    });
    
    // Form submit validation
    form.addEventListener('submit', function(e) {
      if (isGstCheckbox.checked) {
        var gstinValue = gstinField.value.trim();
        if (gstinValue.length !== 15) {
          e.preventDefault();
          gstinField.style.borderColor = '#dc3545';
          gstinError.style.display = 'block';
          gstinField.focus();
          alert('GSTIN must be exactly 15 characters for GST registered suppliers');
          return false;
        }
      }
    });
  });
  
  // Edit supplier function using event delegation
  document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener('click', function(e) {
      if (e.target.closest('.edit-supplier-btn')) {
        const btn = e.target.closest('.edit-supplier-btn');
        const id = btn.getAttribute('data-id');
        const name = btn.getAttribute('data-name');
        const phone = btn.getAttribute('data-phone');
        const gstin = btn.getAttribute('data-gstin');
        const isGst = btn.getAttribute('data-isgst');
        const desc = btn.getAttribute('data-desc');
        editSupplier(id, name, phone, gstin, isGst, desc);
      }
    });
  });
  
  // Edit supplier function
  function editSupplier(id, name, phone, gstin, isGst, desc) {
    document.getElementById('supplierId').value = id;
    document.getElementById('supName').value = name;
    document.getElementById('supPhn').value = phone;
    document.getElementById('gstin').value = gstin;
    document.getElementById('supDesc').value = desc;
    
    // Check if GST registered (ignore "-" as it means no GSTIN)
    const isGstCheckbox = document.getElementById('isGst');
    if (isGst === '1' && gstin && gstin.trim() !== '' && gstin.trim() !== '-') {
      isGstCheckbox.checked = true;
      document.getElementById('gstin').disabled = false;
      document.getElementById('gstinRequired').style.display = 'inline';
    } else {
      isGstCheckbox.checked = false;
      document.getElementById('gstin').disabled = true;
      document.getElementById('gstinRequired').style.display = 'none';
    }
    
    // Change form action and button text
    document.getElementById('supplierForm').action = '<%=contextPath%>/product/master/supplier/edit1.jsp';
    document.getElementById('submitBtn').textContent = 'Update Supplier';
    document.getElementById('submitBtn').className = 'btn btn-success';
    document.getElementById('cancelBtn').style.display = 'inline-block';
    
    // Scroll to form
    document.getElementById('supplierForm').scrollIntoView({ behavior: 'smooth' });
  }
  
  // Reset form function
  function resetForm() {
    document.getElementById('supplierForm').reset();
    document.getElementById('supplierId').value = '0';
    document.getElementById('supplierForm').action = '<%=contextPath%>/product/master/supplier/page1.jsp';
    document.getElementById('submitBtn').textContent = 'Add Supplier';
    document.getElementById('submitBtn').className = 'btn btn-primary';
    document.getElementById('cancelBtn').style.display = 'none';
    document.getElementById('gstin').disabled = true;
    document.getElementById('gstinRequired').style.display = 'none';
  }
  
  // Disable right click for the whole document
  document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
  });
</script>
</body>
</html>
