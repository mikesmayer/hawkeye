function init_meals_index(){
	update_count_breakdown("day");


	$.ajax({
		url: "meals/month_counts",
		cache: false,
		success: function(html){
			console.log("meals/month_counts");
		}
	});

	$.ajax({
		url: "meals/year_counts",
		cache: false,
		success: function(html){
			console.log("meals/year_counts")
		}
	});

	$('#breakdown_by_day_selector').click(function(){
		console.log("day selected");
		update_count_breakdown("day");
	});

	$('#breakdown_by_month_selector').click(function(){
		console.log("month selected");
		update_count_breakdown("month");
	});

	$('#breakdown_by_quarter_selector').click(function(){
		console.log("quarter selected");
		update_count_breakdown("quarter");
	});

	$('#breakdown_by_year_selector').click(function(){
		console.log("year selected");
		update_count_breakdown("year");
	});
}

function update_count_breakdown(selected_granularity){
	console.log(selected_granularity);
		

	$.ajax({
	  url: "meals/detail_counts",
	  type: "GET", 
	  data: { granularity: selected_granularity }, 
	  cache: false,
	  beforeSend: function() {
		$('#count_ajax_loading').show();	
		$('#detail_tbl_container').hide();

	  },
	  success: function(html) {
	    console.log("meals/detail_counts?" + selected_granularity);

		$('#m4m_stats_tbl').dataTable({
		  "sPaginationType": "bootstrap"
		});
		console.log('test');
		$('#count_ajax_loading').hide();	
		$('#detail_tbl_container').show();

	  }
	});

}