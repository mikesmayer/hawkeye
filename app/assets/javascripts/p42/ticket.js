$(document).ready(function(){
	var nowTemp = new Date();
	var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
	
	$('.datepicker').datepicker({
		format: 'yyyy/mm/dd',
		endDate: '-1d',
		autoclose: true
	});
});