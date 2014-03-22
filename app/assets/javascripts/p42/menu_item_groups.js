/*
$('.rest-in-place').bind('failure.rest-in-place', function(event, json){

	console.log("error" + json);
});
*/

$(document).ready(function(){
	
	$('.rest-in-place').each(function(i, obj){
		$(this).bind('failure.rest-in-place', function(event, json){
			var error_count_html = "<div class=\"alert alert-danger fade in\">";
			error_count_html += "Failed to update default meal number. Please enter an integer.";
			error_count_html += "<button type=\"button\"";
			error_count_html += "class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">x</button></div>";
			$('#error_cont').html(error_count_html);
			$(".alert").alert();
		});
	});
})

