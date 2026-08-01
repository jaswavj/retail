<%@page language="java" %>
<%
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Cloud Subscription Ended - JASXBILL</title>
  <link rel="icon" type="image/jpeg" href="billing/jasxbill.jpeg">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <link href="dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="dist/fonts/css/all.min.css">
  <link rel="stylesheet" href="assets/css/theme.css">
  <style>
    .sub-card {
      max-width: 480px;
      text-align: center;
    }

    .sub-status-badge {
      display: inline-flex;
      align-items: center;
      gap: 7px;
      padding: 7px 16px;
      border-radius: 999px;
      font-size: 0.72rem;
      font-weight: 700;
      letter-spacing: 1.2px;
      text-transform: uppercase;
      color: #991b1b;
      background: linear-gradient(135deg, #fef2f2, #fee2e2);
      border: 1.5px solid #fca5a5;
      margin-bottom: 22px;
      animation: badge-pulse 2.5s ease-in-out infinite;
    }

    @keyframes badge-pulse {
      0%, 100% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.25); }
      50%      { box-shadow: 0 0 0 8px rgba(239, 68, 68, 0); }
    }

    .sub-icon-wrap {
      width: 96px;
      height: 96px;
      margin: 0 auto 20px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(145deg, #fff7ed, #ffedd5);
      border: 2px solid #fdba74;
      box-shadow: 0 16px 40px rgba(245, 158, 11, 0.22);
      position: relative;
    }

    .sub-icon-wrap::after {
      content: '';
      position: absolute;
      inset: -6px;
      border-radius: 50%;
      border: 2px dashed rgba(245, 158, 11, 0.35);
      animation: ring-spin 12s linear infinite;
    }

    @keyframes ring-spin {
      from { transform: rotate(0deg); }
      to   { transform: rotate(360deg); }
    }

    .sub-icon-wrap i {
      font-size: 2.4rem;
      color: #ea580c;
      position: relative;
      z-index: 1;
    }

    .sub-title {
      font-size: 1.45rem;
      font-weight: 800;
      color: #111827;
      margin: 0 0 10px;
      line-height: 1.3;
    }

    .sub-subtitle {
      font-size: 0.92rem;
      color: #6b7280;
      margin: 0 0 24px;
      line-height: 1.65;
    }

    .sub-message-box {
      background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
      border: 1.5px solid #fcd34d;
      border-radius: 14px;
      padding: 18px 20px;
      margin-bottom: 22px;
      text-align: left;
    }

    .sub-message-box h3 {
      font-size: 0.88rem;
      font-weight: 700;
      color: #92400e;
      margin: 0 0 8px;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .sub-message-box p {
      font-size: 0.84rem;
      color: #78350f;
      margin: 0;
      line-height: 1.6;
    }

    .sub-steps {
      list-style: none;
      padding: 0;
      margin: 0 0 22px;
      text-align: left;
    }

    .sub-steps li {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 10px 0;
      border-bottom: 1px solid #f3f4f6;
      font-size: 0.82rem;
      color: #4b5563;
    }

    .sub-steps li:last-child {
      border-bottom: none;
      padding-bottom: 0;
    }

    .sub-step-num {
      flex-shrink: 0;
      width: 26px;
      height: 26px;
      border-radius: 50%;
      background: linear-gradient(135deg, #1a2540, #2a3a60);
      color: #c9a227;
      font-size: 0.72rem;
      font-weight: 800;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .sub-footer-note {
      font-size: 0.78rem;
      color: #9ca3af;
      margin: 0;
      padding-top: 16px;
      border-top: 1px solid #f3f4f6;
    }

    .sub-footer-note i {
      color: #c9a227;
      margin-right: 4px;
    }
  </style>
</head>
<body class="login-body">

  <div class="login-bg">
    <div class="bg-orb bg-orb-1"></div>
    <div class="bg-orb bg-orb-2"></div>
    <div class="bg-orb bg-orb-3"></div>
  </div>

  <div class="login-main">
    <div class="lc-card sub-card">

      <div class="lc-brand">
        <div class="lc-brand-icon">
          <img src="billing/jasxbill.jpeg" alt="JASXBILL Logo" class="lc-logo-img">
        </div>
        <h1 class="lc-brand-name">JASXBILL</h1>
        <p class="lc-brand-tagline">Smart Business Management System</p>
      </div>

      <div class="lc-divider"></div>

      <div class="sub-status-badge">
        <i class="fas fa-circle"></i>
        Service Unavailable
      </div>

      <div class="sub-icon-wrap">
        <i class="fas fa-cloud-slash"></i>
      </div>

      <h2 class="sub-title">Your Cloud Subscription Has Ended</h2>
      <p class="sub-subtitle">
        Access to this application is temporarily suspended because your cloud hosting plan is no longer active.
      </p>

      <div class="sub-message-box">
        <h3>
          <i class="fas fa-user-shield"></i>
          Action Required
        </h3>
        <p>
          Please contact your <strong>Cloud Account Holder</strong> to renew your cloud space and restore service.
        </p>
      </div>

      <ul class="sub-steps">
        <li>
          <span class="sub-step-num">1</span>
          <span>Reach out to the person or team who manages your cloud hosting account.</span>
        </li>
        <li>
          <span class="sub-step-num">2</span>
          <span>Complete the cloud space renewal or payment process.</span>
        </li>
        <li>
          <span class="sub-step-num">3</span>
          <span>Once renewed, your administrator will reactivate access to JASXBILL.</span>
        </li>
      </ul>

      <p class="sub-footer-note">
        <i class="fas fa-lock"></i>
        Your data remains secure. Service will resume after renewal.
      </p>

    </div>
  </div>

  <footer class="login-footer">
    <div class="lfoot-inner">
      <div class="lfoot-brand">
        <i class="fas fa-building"></i>
        <span>JASXBILL &mdash; Professional Billing Software</span>
      </div>
      <div class="lfoot-links">
        <a href="mailto:jasxbill@gmail.com" class="lfoot-link">
          <i class="fas fa-envelope"></i>
          jasxbill@gmail.com
        </a>
        <a href="https://jasxbill.in" target="_blank" class="lfoot-link">
          <i class="fas fa-globe"></i>
          jasxbill.in
        </a>
        <a href="tel:+918667214152" class="lfoot-link">
          <i class="fas fa-phone"></i>
          +91 8667214152 / +91 9597451419
        </a>
      </div>
    </div>
  </footer>

</body>
</html>
