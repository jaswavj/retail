//////////////////////////////right click disable/////
/*document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
  });
document.addEventListener('keydown', e => {
    if (
      e.key === 'F12' ||
      (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J'))
    ) {
      e.preventDefault();
    }
  });*/

/////////////////////Set Input 0 -- to written in //oninput
function setDefaultValue(input) {
    let value = input.value;
    if (value.startsWith('0') && value.length > 1) {
        value = value.replace(/^0+/, '');
        input.value = value;
    }
    if (input.value === "") {
        input.value = "0";
    }
}

/////////////////// deletes history of browser on history back
// window.onload = function () {
//     history.pushState(null, null, location.href);
//     window.onpopstate = function () {
//         history.pushState(null, null, location.href);
//     };
// }

////////////////// Input Validation for Numbers and Decimals add classes to input fields
// .only-numbers for integer only
// .only-decimal for decimal numbers
// .only-decimal-negative for decimal numbers with negative sign allowed
document.addEventListener("DOMContentLoaded", function () {
  
  // Integer only
  document.querySelectorAll(".only-numbers").forEach(function (input) {
    input.addEventListener("keypress", function (e) {
      if (!/[0-9]/.test(e.key)) {
        e.preventDefault();
      }
    });

    input.addEventListener("input", function () {
      this.value = this.value.replace(/[^0-9]/g, '');
    });
  });

  // Decimal only
  document.querySelectorAll(".only-decimal").forEach(function (input) {
    input.addEventListener("keypress", function (e) {
      if (!/[0-9.]/.test(e.key)) {
        e.preventDefault();
      }
      // Prevent more than one dot
      if (e.key === '.' && this.value.includes('.')) {
        e.preventDefault();
      }
    });

    input.addEventListener("input", function () {
      this.value = this.value
        .replace(/[^0-9.]/g, '')
        .replace(/(\..*)\./g, '$1'); // allow only one dot
    });
  });

  // Decimal + Negative
  document.querySelectorAll(".only-decimal-negative").forEach(function (input) {
    input.addEventListener("keypress", function (e) {
      if (!/[0-9.-]/.test(e.key)) {
        e.preventDefault();
      }
      // Only one minus at start
      if (e.key === '-' && (this.value.includes('-') || this.selectionStart !== 0)) {
        e.preventDefault();
      }
      // Only one dot allowed
      if (e.key === '.' && this.value.includes('.')) {
        e.preventDefault();
      }
    });

    input.addEventListener("input", function () {
      this.value = this.value
        .replace(/[^0-9.-]/g, '')
        .replace(/(?!^)-/g, '')         // remove extra '-' not at start
        .replace(/(\..*)\./g, '$1');    // only one dot
    });
  });

});

////////////////////

// Table styling is now handled by theme.css
// document.addEventListener("DOMContentLoaded", function() {
//     // Force header cells
//     document.querySelectorAll("table thead tr th").forEach(function(th) {
//         th.style.setProperty("background-color", "#4e73df", "important");
//         th.style.setProperty("color", "#fff", "important");
//     });

//     // Force body cells
//     document.querySelectorAll("table tfoot tr td").forEach(function(td) {
//         td.style.setProperty("background-color", "#1cc88a", "important");
//         td.style.setProperty("color", "#000", "important");
//     });
// });

  // Disable right click for the whole document

//////////////////// Toggle Sidebar
/*function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const sidebarTexts = document.querySelectorAll('.sidebar-text');

    if (sidebar.style.width === '50px') {
        sidebar.style.width = '200px';
        sidebarTexts.forEach(text => text.style.display = 'inline');
    } else {
        sidebar.style.width = '50px';
        sidebarTexts.forEach(text => text.style.display = 'none');
    }
}*/



//////////////////// Mobile bottom bar — clear iOS Safari URL / home indicator
(function () {
    function adjustMobileBottomBar() {
        if (window.innerWidth > 768) {
            document.documentElement.style.removeProperty('--mobile-bottom-offset');
            document.querySelectorAll('.grp-act').forEach(function (bar) {
                bar.style.paddingBottom = '';
            });
            return;
        }
        var bars = document.querySelectorAll('.grp-act');
        if (!bars.length) return;

        var vv = window.visualViewport;
        var browserOverlap = 0;
        if (vv) {
            browserOverlap = Math.max(0, window.innerHeight - vv.height - vv.offsetTop);
        }

        var maxBarHeight = 0;
        bars.forEach(function (bar) {
            if (getComputedStyle(bar).position !== 'fixed') return;
            var pad = Math.max(12, browserOverlap);
            bar.style.paddingBottom = pad + 'px';
            maxBarHeight = Math.max(maxBarHeight, bar.offsetHeight + pad);
        });

        if (maxBarHeight > 0) {
            document.documentElement.style.setProperty('--mobile-bottom-offset', maxBarHeight + 'px');
        }
    }

    document.addEventListener('DOMContentLoaded', adjustMobileBottomBar);
    window.addEventListener('load', adjustMobileBottomBar);
    window.addEventListener('resize', adjustMobileBottomBar);
    window.addEventListener('orientationchange', adjustMobileBottomBar);
    if (window.visualViewport) {
        window.visualViewport.addEventListener('resize', adjustMobileBottomBar);
        window.visualViewport.addEventListener('scroll', adjustMobileBottomBar);
    }
})();