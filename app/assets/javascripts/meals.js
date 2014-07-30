var breakdown_tbl_granularity;
var date_range;
var meals_selected_restaurant;
var category_id;


function init_meals_index(){
	breakdown_tbl_granularity = "day";
	date_range = "all";
	meals_selected_restaurant = "p42";
	
	update_count_breakdown();
	update_counts_by_month();
	update_counts_by_year();
	update_product_mix();

	/* function that just sets up all of the click handlers for the page */
	setup_click_handlers();




}


/* called whenever the date range is changed 
*  this will update:
*  the counts breakdown table (update_count_breakdown() function is called)
*  the counts by month table (update_counts_by_month() function is called)
*  the counts by year table (update_counts_by_year() function is called)
*/
function update_date_range(){
	//console.log("Date range: " + date_range);
	update_count_breakdown();
	update_counts_by_month();
	update_counts_by_year();
	update_meal_info_boxes();
	update_product_mix();
	get_category_breakdown();
}

function meals_update_restaurant_selection(){
	console.log(meals_selected_restaurant);
	update_count_breakdown();
	update_counts_by_month();
	update_counts_by_year();
	update_meal_info_boxes();
	update_product_mix();

	update_category_selector();
}


function update_category_selector(){
	$('#category_product_mix_container').html('');
	category_id = null;
	if(meals_selected_restaurant == "p42"){
		$('#p42_category_select_cont').removeClass("hidden");
		$('#tacos_category_select_cont').addClass("hidden");		
	}else {
		$('#p42_category_select_cont').addClass("hidden");
		$('#tacos_category_select_cont').removeClass("hidden");				
	}
}


function update_product_mix(){

	$.ajax({
		url: "meals/product_mix",
		type: "GET",
		data: {
			restaurant: meals_selected_restaurant,
			date_range: date_range
		},
		cache: false,
		beforeSend: function() {
			$('#product_mix_spinner').show();	
			$('#product_mix_container').hide();
		},
		success: function(html){
			$('#product_mix_spinner').hide();	
			$('#product_mix_container').show();

			if(date_range == "all"){
				$('#product_mix_dates').html("<b>All time</b>");
			}else if(date_range == "current_year"){
				$('#product_mix_dates').html("<b>Current year</b>");
			}else if(date_range == "current_month"){
				$('#product_mix_dates').html("<b>Current month</b>");
			}else if(date_range == "current_week"){
				$('#product_mix_dates').html("<b>Current week</b>");
			}
			
		}
	});

}

function update_count_breakdown(){
	console.log(breakdown_tbl_granularity);
	console.log(date_range);

	$.ajax({
	  url: "meals/detail_counts",
	  type: "GET", 
	  data: { 
	  	granularity: breakdown_tbl_granularity,
	  	date_range: date_range,
	  	restaurant: meals_selected_restaurant
	  }, 
	  cache: false,
	  beforeSend: function() {
		$('#count_detail_body_container').show();	
		$('#detail_tbl_container').hide();

	  },
	  success: function(html) {
	    //console.log("meals/detail_counts?" + breakdown_tbl_granularity);

		$('#m4m_stats_tbl').dataTable({
			"sPaginationType": "bootstrap",
			"bFilter": false
		});
		
		$('#count_detail_body_container').hide();	
		$('#detail_tbl_container').show();

	  }
	});

}


function update_counts_by_month(){
	$.ajax({
		url: "meals/month_counts",
		cache: false,
		data: {
			date_range: date_range,
			restaurant: meals_selected_restaurant
		},
		beforeSend: function(){
			$('#count_month_body_container').show();
			$('#m4m_month_container').hide();
		},
		success: function(html){
			$('#count_month_body_container').hide();
			$('#m4m_month_container').show();

			//console.log("meals/month_counts");
			
			$('#m4m_month_tbl').dataTable({
			  "sPaginationType": "bootstrap",
			  "pagingType": "simple",
			  "ordering": false,
			  "bFilter": false,
			  "bLengthChange": false
			});
		}
	});
}


function update_counts_by_year(){
	$.ajax({
		url: "meals/year_counts",
		cache: false,
		data: {
			date_range: date_range,
			restaurant: meals_selected_restaurant
		},
		beforeSend: function(){
			$('#count_year_body_container').show();
			$('#m4m_year_container').hide();
		},
		success: function(html){
			$('#count_year_body_container').hide();
			$('#m4m_year_container').show();
			//console.log("meals/year_counts")
		}
	});	
}


function update_meal_info_boxes(){
	$.ajax({
		url: "meals/count_totals",
		cache: false,
		data: {
			date_range: date_range, 
			restaurant: meals_selected_restaurant
		},
		beforeSend: function(){
			$('#loading_spinner_date_picker').show();
			
		},
		success: function(data){
			$('#loading_spinner_date_picker').hide();
			console.log(data);
			total = addCommas( data.total.toFixed(0) );
			m4m = addCommas( data.m4m.toFixed(0) );
			dym = addCommas( data.dym.toFixed(0) );
			apparel = addCommas( data.apparel.toFixed(0) );
			tip_jar = addCommas( data.tip_jar.toFixed(0) );

			$('#total_meals_info_box').html(total);
			$('#m4m_meals_info_box').html(m4m);
			$('#dym_meals_info_box').html(dym);
			$('#apparel_meals_info_box').html(apparel);
			$('#tip_jar_meals_info_box').html(tip_jar);
		}
	});	
}


function get_category_breakdown(){
	console.log("Category: " + category_id);

	if(category_id){
		$.ajax({
			url: "meals/category_product_mix",
			cache: false,
			data: {
				restaurant: meals_selected_restaurant,
				date_range: date_range,
				category_id: category_id
			},
			beforeSend: function(){
				$('#category_product_mix_spinner').show();
				$('#category_product_mix_container').hide();
			},
			success: function(data){
				$('#category_product_mix_spinner').hide();
				$('#category_product_mix_container').show();
			}
		});
	}
}


function setup_click_handlers(){
	/* Click handlers for granulatrity on Counts breakdown table */
	$('#breakdown_by_day_selector').click(function(){
		breakdown_tbl_granularity = "day";
		update_count_breakdown();
	});

	$('#breakdown_by_month_selector').click(function(){
		breakdown_tbl_granularity = "month";
		update_count_breakdown();
	});

	$('#breakdown_by_quarter_selector').click(function(){
		breakdown_tbl_granularity = "quarter";
		update_count_breakdown();
	});

	$('#breakdown_by_year_selector').click(function(){
		breakdown_tbl_granularity = "year";
		update_count_breakdown();
	});
	/* end counts breakdown table granulatrity callback handlers */


	/* click hanlders for page date scope */
	$('#date_filter_all_time').click(function(){
		$('#custom_range_input').hide();
		date_range = "all";
		update_date_range();
	});

	$('#date_filter_current_year').click(function(){
		$('#custom_range_input').hide();
		date_range = "current_year";
		update_date_range();
	});

	$('#date_filter_current_month').click(function(){
		$('#custom_range_input').hide();
		date_range = "current_month";
		update_date_range();
	});

	$('#date_filter_current_week').click(function(){
		$('#custom_range_input').hide();
		date_range = "current_week";
		update_date_range();
	});


	$('#date_filter_daterange').click(function(){
		$('#custom_range_input').show();
	});


	$('#date_range_filter_btn').click(function(){
		var start_range = $('#date_range_start').val();
		var end_range = $('#date_range_end').val();
		console.log("start" + start_range);
		console.log("end" + end_range);
		date_range = start_range + "T" + end_range;
		console.log(date_range);
		update_date_range();
	});
	/* end click handlers for page date scope */


	/* click handlers for restaurant selection */
	$('#meals_p42_selector').click(function(){
		meals_selected_restaurant = "p42";
		meals_update_restaurant_selection();
	});

	$('#meals_tacos_selector').click(function(){
		meals_selected_restaurant = "tacos";
		meals_update_restaurant_selection();
	});

	/* end click handlers for restaurant selection */

	/* click event handler for the category select dropdown list */
	$('#p42_cat_select').change(function(){
		category_id = $(this).children(":selected").val();
		get_category_breakdown();
	});

	$('#tacos_cat_select').change(function(){
		category_id = $(this).children(":selected").val()
		get_category_breakdown();
	});
	/* end click handler for category */
}

