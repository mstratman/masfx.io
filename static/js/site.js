"use strict";

const sidebarBreak = 992;

/* ====== Define JS Constants ====== */
const sidebarToggler = document.getElementById('docs-sidebar-toggler');
const sidebar = document.getElementById('docs-sidebar');
const sidebarLinks = document.querySelectorAll('#docs-sidebar .scrollto');

//const sidebarHeadings = document.querySelectorAll("#docs-sidebar .nav-collapse");


// TODO: set up initial quick or comprehensive content

function loadIsQuick() {
  if (typeof(Storage) !== "undefined") {
    return JSON.parse(localStorage.getItem("isQuick"));
  } else {
    console.log("NO LOCAL STORAGE");
    return false;
  }
}
function setIsQuick(isQ) {
  isQuick = isQ;
  if (typeof(Storage) !== "undefined") {
    return localStorage.setItem("isQuick", JSON.stringify(isQuick));
  } else {
    console.log("NO LOCAL STORAGE");
    return undefined;
  }
}

var isQuick = loadIsQuick();

const quickContent = document.querySelectorAll('.cq');
const comprehensiveContent = document.querySelectorAll('.cc');
var selectQuick = document.getElementById('select-quick');
var selectComprehensive = document.getElementById('select-comprehensive');

if (isQuick) {
  selectQuick.classList.add('selected-guide');
} else {
  selectComprehensive.classList.add('selected-guide');
}
showHideContent();

selectQuick.addEventListener('click', (e) => {
  setIsQuick(true);
	if (selectQuick.classList.contains('selected-guide')) {
    return;
  }
  selectQuick.classList.add('selected-guide');
  selectComprehensive.classList.remove('selected-guide');
  showHideContent();
});
selectComprehensive.addEventListener('click', (e) => {
  setIsQuick(false);
	if (selectComprehensive.classList.contains('selected-guide')) {
    return;
  }
  selectQuick.classList.remove('selected-guide');
  selectComprehensive.classList.add('selected-guide');
  showHideContent();
});


function showHideContent() {
  if (isQuick) {
    quickContent.forEach((content) => {
      content.style.display = "";
    });
    comprehensiveContent.forEach((content) => {
      content.style.display = "none";
    });
  } else {
    quickContent.forEach((content) => {
      content.style.display = "none";
    });
    comprehensiveContent.forEach((content) => {
      content.style.display = "";
    });
  }
}



function responsiveSidebar() {
    let w = window.innerWidth;
	if(w >= sidebarBreak) {
	    // if larger 
		sidebar.classList.remove('sidebar-hidden');
		sidebar.classList.add('sidebar-visible');
		
	} else {
	    // if smaller
	    sidebar.classList.remove('sidebar-visible');
		sidebar.classList.add('sidebar-hidden');
	}
};

sidebarToggler.addEventListener('click', () => {
	if (sidebar.classList.contains('sidebar-visible')) {
		sidebar.classList.remove('sidebar-visible');
		sidebar.classList.add('sidebar-hidden');
		
	} else {
		sidebar.classList.remove('sidebar-hidden');
		sidebar.classList.add('sidebar-visible');
	}
});


/* ===== Smooth scrolling ====== */
/*  Note: You need to include smoothscroll.min.js (smooth scroll behavior polyfill) on the page to cover some browsers */
/* Ref: https://github.com/iamdustan/smoothscroll */

sidebarLinks.forEach((sidebarLink) => {
	
	sidebarLink.addEventListener('click', (e) => {
		
		e.preventDefault();
		
		var href = sidebarLink.getAttribute("href");
    if (href.indexOf('#') == -1) {
      return;
    }
		var target = href.replace('#', '');
		
		//console.log(target);
		
        document.getElementById(target).scrollIntoView({ behavior: 'smooth' });
        
        
        //Collapse sidebar after clicking
		if (sidebar.classList.contains('sidebar-visible') && window.innerWidth < sidebarBreak){
			
			sidebar.classList.remove('sidebar-visible');
		    sidebar.classList.add('sidebar-hidden');
		} 
		
    });
	
});




window.onload=function() 
{ 
    responsiveSidebar(); 

  /* ===== Gumshoe SrollSpy ===== */
  /* Ref: https://github.com/cferdinandi/gumshoe  */
  // Initialize Gumshoe
  var spy = new Gumshoe('#docs-nav a', {
    offset: 69 //sticky header height
  });

  //var lightbox = new SimpleLightbox('a.lightbox', {/* options */});
  Fancybox.bind("[data-fancybox]", {});
  checkDonePages();
};

window.onresize=function() 
{ 
    responsiveSidebar(); 
};


function checkDonePages() {
  var pgid = document.getElementById('current_page_id');
  if (! pgid) { return; }
  var current_page_id = pgid.value;
  if (typeof(Storage) !== "undefined") {
    localStorage.setItem(current_page_id, "done");

    var checkboxes = document.querySelectorAll('.page_done');
    checkboxes.forEach((cb) => {
      var id = cb.id;
      var done = localStorage.getItem(id);
      //console.log("Considering id=" + id + " val=" + done);
      if (done == "done") {
        cb.classList.remove('d-none');
      }
    });

    var str = document.getElementById('sidebar_structure').textContent;
    var chapters = JSON.parse(str);
    chapters.forEach((ch) => {
      var ch_is_done = true;
      ch.pages.forEach((p) => {
        if (p.id) {
          var done = localStorage.getItem(p.id);
          if (! (done && done == "done")) {
            ch_is_done = false;
          }
        }
      });
      if (ch_is_done) {
        var cb = document.getElementById(ch.id);
        cb.classList.remove('d-none');
      }
    });

  } else {
    console.log("NO LOCAL STORAGE");
    return undefined;
  }
}
// for debugging - in browser
function resetDonePages() {
    var checkboxes = document.querySelectorAll('.page_done');
    checkboxes.forEach((cb) => {
      var id = cb.id;
      localStorage.setItem(id, "INCOMPLETE");
      cb.classList.add('d-none');
      var done = localStorage.getItem(id);
      console.log("Considering id=" + id + " val=" + done);
    });
}
