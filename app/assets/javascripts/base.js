// change language when user choose language selecter
function change_language(language) {
  if (location.href.match(/locale=[a-z\\-]+/)) { 
  	location.href = location.href.replace(/locale=([a-z\\-]+)/, 'locale=' + language.value);
  } else {
  	location.href += ((location.href.match(/\\?/)) ? '&' : '?') + 'locale=' + language.value;
  }
}
// change language - end

// remove class function
function remove_class(node, class_name) {
  if (node && node.className.match(class_name)) {
  	var classReg = new RegExp("(.*)[^\w]?\s?"+ class_name +"($|[^\w])(.*)");
  	var current_class = node.className;
  	current_class = current_class.replace(classReg, "$1 $3");
  	node.setAttribute("class", current_class);
  }
}

// add class function
function add_class(node, class_name) {
  if (node) {
  	node.setAttribute("class", node.className + " " + class_name);
  }
}

// change submit button status
function trigger_submit_btn(status) {
  var submit_btn = document.getElementById("submit-btn");
  // check button exist
  if (submit_btn) {
    var exist = submit_btn.getAttribute("disabled");
    if (status == "enabled" && exist) {
      submit_btn.removeAttribute("disabled");
    } else if (status == "disabled" && !exist) {
      submit_btn.setAttribute("disabled", "disabled");
    }
  }
}