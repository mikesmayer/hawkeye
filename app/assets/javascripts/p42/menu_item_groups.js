/*
$('.rest-in-place').bind('failure.rest-in-place', function(event, json){

	console.log("error" + json);
});
*/

$(document).ready(function(){
	$('.rest-in-place').each(function(i, obj){
		$(this).bind('failure.rest-in-place', function(event, json){
			$('#error_cont').html("Failed to update default meal number: " + json["default_meal_modifier"].join(", "));
		});
	});
})

