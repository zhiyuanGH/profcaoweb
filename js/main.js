function publi(){
	var x = document.getElementById("publication");
	var y = document.getElementById("demo");
	var z = document.getElementById("patent");
	var b = document.getElementById("bks");
	x.style.display="";
	y.style.display="none";
	z.style.display="none";
	b.style.display="none";
}
function dem(){
	var x = document.getElementById("publication");
	var y = document.getElementById("demo");
	var z = document.getElementById("patent");
	var b = document.getElementById("bks");
	x.style.display="none";
	y.style.display="";
	z.style.display="none";
	b.style.display="none";
}

function bks(){
	var x = document.getElementById("publication");
	var y = document.getElementById("demo");
	var z = document.getElementById("patent");
	var b = document.getElementById("bks");
	x.style.display="none";
	y.style.display="none";
	z.style.display="none";
	b.style.display="";
}

function pa(){
	var x = document.getElementById("publication");
	var y = document.getElementById("demo");
	var z = document.getElementById("patent");
	var b = document.getElementById("bks");
	x.style.display="none";
	y.style.display="none";
	b.style.display="none";
	z.style.display="";
}

function grants_all(){
	var x = document.getElementById("grant_recent");
	var y = document.getElementById("grant_all");
	x.style.display="none";
	y.style.display="";
}

function grants_recent(){
	var x = document.getElementById("grant_recent");
	var y = document.getElementById("grant_all");
	x.style.display="";
	y.style.display="none";
}


function load_home(){
	$("#changeable").load("sub_parts/home_part.html");
	$("#navigate li").removeClass("active");
	$("#navigate li:nth-child(1)").addClass("active");
}

function load_grants(){
	$("#changeable").load("sub_parts/grants_part.html");
	$("#navigate li").removeClass("active");
	$("#navigate li:nth-child(2)").addClass("active");
}


function load_pubs(){
	$("#changeable").load("sub_parts/pubs_part.html");
	$("#navigate li").removeClass("active");
	$("#navigate li:nth-child(3)").addClass("active");
}

function load_teach(){
	$("#changeable").load("sub_parts/teaching_part.html");
	$("#navigate li").removeClass("active");
	$("#navigate li:nth-child(4)").addClass("active");
}

function load_serve(){
	$("#changeable").load("sub_parts/serve_part.html");
	$("#navigate li").removeClass("active");
	$("#navigate li:nth-child(5)").addClass("active");
}

function load_award(){
	$("#changeable").load("sub_parts/award_part.html");
	$("#navigate li").removeClass("active");
	$("#navigate li:nth-child(6)").addClass("active");
}

function load_group(){
    $("#changeable").load("sub_parts/group_part.html");
	$("#navigate li").removeClass("active");
	$("#navigate li:nth-child(7)").addClass("active");
}


function show_cs(){
	var x = document.getElementById("current_s");
	var y = document.getElementById("previous_s");
	x.style.display="";
	y.style.display="none";
}

function show_ps(){
	var x = document.getElementById("current_s");
	var y = document.getElementById("previous_s");
	x.style.display="none";
	y.style.display="";
}

