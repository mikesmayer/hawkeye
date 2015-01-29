var item_sales_breakdown_granulatrity;
var item_sales_index_date_range;
var selected_restaurant;
var item_sales_category_id;
var sum_type;

function init_item_sales_index(){
	item_sales_breakdown_granulatrity = "day";
	item_sales_index_date_range = "current_week";
	selected_restaurant = "p42";
	sum_type = "net_price"

	update_aggregate_item_sales_breakdown();
	update_sales_info_boxes();
	
	item_sales_setup_click_handlers();

	update_category_sales_chart();
}


function item_sales_update_date_range(){
	console.log("item_sales_update_date_range");
	
	update_aggregate_item_sales_breakdown();
	update_sales_info_boxes();
	update_item_sales_details();

	update_details_csv_download_url();
	update_category_sales_chart();
	item_sales_get_category_breakdown();
}

function update_restaurant_selection(){
	console.log("update restaurant" + selected_restaurant);
	update_sales_info_boxes();
	update_item_sales_details();
	update_aggregate_item_sales_breakdown();
	
	update_details_csv_download_url();
	update_category_sales_chart();

	update_category_selector_item_sales_page();

	item_sales_get_category_breakdown();

	if(selected_restaurant == "p42"){
		$('#p42_cat_select').val("-1");
	}else if(selected_restaurant == "tacos"){
		$('#tacos_cat_select').val("-1");
	}
}


function update_aggregate_item_sales_breakdown(){

	$.ajax({
	  url: "item_sales/aggregate_items",
	  type: "GET", 
	  data: { 
	  	granularity: item_sales_breakdown_granulatrity,
	  	date_range: item_sales_index_date_range,
	  	restaurant: selected_restaurant
	  }, 
	  cache: false,
	  beforeSend: function() {
		$('#aggreage_loading_spinner').show();	
		$('#aggregate_tbl_container').hide();

	  },
	  success: function(html) {
	    //console.log("meals/detail_counts?" + breakdown_tbl_granularity);

		$('#aggregate-item-sales-table').dataTable({
			"sPaginationType": "bootstrap",
			"bFilter": false
		});
		
		$('#aggreage_loading_spinner').hide();	
		$('#aggregate_tbl_container').show();

	  }
	});

}

function update_sales_info_boxes(){
	$.ajax({
		url: "item_sales/sales_totals",
		cache: false,
		data: {
			date_range: item_sales_index_date_range,
			restaurant: selected_restaurant
		},
		beforeSend: function(){
			//$('#loading_spinner_date_picker').show();
			
		},
		success: function(data){
			//$('#loading_spinner_date_picker').hide();
			console.log(data);
			net_sales = addCommas( data.net_sales.toFixed(0) );
			discount_totals = addCommas( data.discount_totals.toFixed(0) );
			m4m_totals = addCommas( data.m4m_totals.toFixed(0) );
			food_totals = addCommas( (data.food_sales + data.catering_sales).toFixed(0) );
			merch_totals = addCommas( data.merch_sales.toFixed(0) );

			$('#net_sales_info_box').html("$" + net_sales);
			$('#discounts_info_box').html("$" + discount_totals);
			$('#m4m_info_box').html(m4m_totals);
			$('#food_sales_info_box').html("$" + food_totals);
			$('#merch_sales_info_box').html("$" + merch_totals);
		}
	});	
}


function update_category_sales_chart(){
	$.ajax({
		url: "item_sales/category_totals",
		type: "GET",
		cache: false,
		data: {
			date_range: item_sales_index_date_range,
			restaurant: selected_restaurant
		},
		beforeSend: function(){
			$('#cat_net_sales_cont').empty();
			//$('#category_chart').empty();
		},
		success: function(data){
			//console.log("Updating category sales chart");
			//console.log(data);
			
			var columns = data.columns;
			var series_data = data.totals;
			var total = data.all_cat_total;
			var series = [{
				data: series_data
			}];
			//console.log(columns);
			//console.log(series);
			var date_text = item_sales_index_date_range;
			if(item_sales_index_date_range == "all"){
				date_text = "<b>All time</b>";
			}else if(item_sales_index_date_range == "current_year"){
				date_text = "<b>Current year</b>";
			}else if(item_sales_index_date_range == "current_month"){
				date_text = "<b>Current month</b>";
			}else if(item_sales_index_date_range == "current_week"){
				date_text = "<b>Current week</b>";
			}

			if ( total > 0.01 ){
				//$('#chart1_cont').show();
				$('#selected_dates').html(date_text);
				$('#cat_net_sales_cont').html("<div id=\"category_chart\" style=\"width:100%; height:500px;\"></div>");
				setupCategoryChart(columns, series, total);
			} else {
				$('#selected_dates').html("No sales data available for " + date_text);
			}
			
		}
	});


	//var columns = ['Africa', 'America', 'Asia', 'Europe', 'Oceania'];
	/*var series = [{
            data: [107, 31, 635, 203, 2]
        }];
        */

	
}


function item_sales_get_category_breakdown(){

	if(item_sales_category_id){
		$.ajax({
			url: "item_sales/item_totals",
			cache: false,
			type: "GET",
			data: {
				date_range: item_sales_index_date_range,
				restaurant: selected_restaurant,
				category_id: item_sales_category_id,
				sum_type: sum_type
			},
			beforeSend: function(){
				$('#category_product_mix_spinner').show();
				//$('#item_sales_items_container').hide();
				$('#item_sales_items_container').empty();
			},
			success: function(data){
				$('#category_product_mix_spinner').hide();
				$('#item_sales_items_container').show();
				//console.log("item sales breakdown:" + data);
				var columns = data.columns;
				var series_data = data.totals;
				var quantity_series_data = data.quantities;
				
				if(sum_type == "quantity"){
					var series = [{
						data: quantity_series_data
					}];
					var total = data.all_item_quantity_total;

				}else {
					var series = [{
						data: series_data
					}];
					var total = data.all_item_total;

				}
				
				

	
				
				console.log("Cat id: " + item_sales_category_id);

				if( total > 0.01){
					//$('#chart1_cont').show();
					$('#item_sales_items_container').html("<div id=\"item_chart\" style=\"width:100%; height:400px;\"></div>");
					setup_item_chart(columns, series, total);
				} else {
					$('#item_sales_items_container').html("<h5 class=\"text-centered\">No data available.</h5>");
				}
			}
		});
	}else {
		$('#item_sales_items_container').empty();
	}
}

function setupCategoryChart(columns, series, total){

	$('#category_chart').highcharts({
        chart: {
            type: 'bar'
        },
        colors: ['#008cba', '#990000'],
        title: {
            text: null
        },/*
        subtitle: {
            text: 'Source: Wikipedia.org'
        },*/
        xAxis: {
            categories: columns,
            title: {
                text: null
            }
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Net Sales'
            },
            labels: {
                overflow: 'justify'
            }
        },
        tooltip: {
            formatter: function() {
                return '<b>'+ this.x +'</b><br/>'+
                '$'+ addCommas(this.y) + '<br/>' +
                'Percent of total: ' + ((this.y/total)*100).toFixed(2) + '%';
            }
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true,
                    formatter: function() {
                    	return '$' + addCommas(this.y);
                    }
                }
            }
        },
        legend: {
        	enabled: false
            /*
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'top',
            x: -40,
            y: 100,
            floating: true,
            borderWidth: 1,
            backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor || '#FFFFFF'),
            shadow: true
            */
        },
        credits: {
            enabled: false
        },
        series: series
    });
}

function setup_item_chart(columns, series, total){
	var x_axis_label;
	if(sum_type == "quantity"){
		x_axis_label = "Quantity Sold";
	}else if(sum_type == "net_price"){
		x_axis_label = "Net Sales"
	}

	$('#item_chart').highcharts({
        chart: {
            type: 'bar'
        },
        colors: ['#990000', '#008cba'],

        title: {
            text: null
        },
        xAxis: {
            categories: columns,
            title: {
                text: null
            }
        },
        yAxis: {
            min: 0,
            title: {
                text: x_axis_label
            },
            labels: {
                overflow: 'justify'
            }
        },
        tooltip: {
            formatter: function() {
            	if(sum_type == "net_price"){
	                return '<b>'+ this.x +'</b><br/>'+
	                '$'+ addCommas(this.y) + '<br/>' +
	                'Percent of total: ' + ((this.y/total)*100).toFixed(2) + '%';
            	}else if(sum_type == "quantity"){
            		return '<b>'+ this.x +'</b><br/>'+
	                'Total sold: ' + addCommas(total.toFixed(0)) + '<br/>' +
	                'Percent of total: ' + ((this.y/total)*100).toFixed(2) + '%';
            	}

            }
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true,
                    formatter: function() {
                    	if(sum_type == "net_price"){
                    		return '$' + addCommas(this.y);
                    	}else if(sum_type == "quantity"){
                    		return addCommas(this.y);
                    	}
                    }
                }
            }
        },
        legend: {
        	enabled: false
        },
        credits: {
            enabled: false
        },
        series: series
    });

}

function update_category_selector_item_sales_page(){
	item_sales_category_id = null;
	if(selected_restaurant == "p42"){
		$('#p42_category_select_cont').removeClass("hidden");
		$('#tacos_category_select_cont').addClass("hidden");		
	}else {
		$('#p42_category_select_cont').addClass("hidden");
		$('#tacos_category_select_cont').removeClass("hidden");				
	}
}

function item_sales_setup_click_handlers(){

	/* Click handlers for granulatrity on Counts breakdown table */
	$('#breakdown_by_day_selector').click(function(){
		item_sales_breakdown_granulatrity = "day";
		update_aggregate_item_sales_breakdown();
	});

	$('#breakdown_by_month_selector').click(function(){
		item_sales_breakdown_granulatrity = "month";
		update_aggregate_item_sales_breakdown();
	});

	$('#breakdown_by_quarter_selector').click(function(){
		item_sales_breakdown_granulatrity = "quarter";
		update_aggregate_item_sales_breakdown();
	});

	$('#breakdown_by_year_selector').click(function(){
		item_sales_breakdown_granulatrity = "year";
		update_aggregate_item_sales_breakdown();
	});
	/* end counts breakdown table granulatrity callback handlers */



	/* click hanlders for page date scope */
	$('#date_filter_all_time').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "all";
		item_sales_update_date_range();
	});

	$('#date_filter_current_year').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "current_year";
		item_sales_update_date_range();
	});

	$('#date_filter_current_month').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "current_month";
		item_sales_update_date_range();
	});

	$('#date_filter_current_week').click(function(){
		$('#custom_range_input').hide();
		item_sales_index_date_range = "current_week";
		item_sales_update_date_range();
	});


	$('#date_filter_daterange').click(function(){
		$('#custom_range_input').show();
	});


	$('#date_range_filter_btn').click(function(){
		var start_range = $('#date_range_start').val();
		var end_range = $('#date_range_end').val();
		console.log("start" + start_range);
		console.log("end" + end_range);
		item_sales_index_date_range = start_range + "T" + end_range;
		console.log(date_range);
		item_sales_update_date_range();
	});
	/* end click handlers for page date scope */


	/* click handlers for restaurant selection */
	$('#p42_selector').click(function(){
		selected_restaurant = "p42";
		update_restaurant_selection();
	});

	$('#tacos_selector').click(function(){
		selected_restaurant = "tacos";
		update_restaurant_selection();
	});

	/* end click handlers for restaurant selection */

	/* click event handler for the category select dropdown list */
	$('#p42_cat_select').change(function(){
		item_sales_category_id = $(this).children(":selected").val();
		item_sales_get_category_breakdown();
	});

	$('#tacos_cat_select').change(function(){
		item_sales_category_id = $(this).children(":selected").val()
		item_sales_get_category_breakdown();
	});
	/* end click handler for category */

	/* click handlers for the quantity or net price selector for the item sales breakdown chart */
	$('#tacos_net_sales_selector').click(function(){
		sum_type = "net_price";
		item_sales_get_category_breakdown();
	});

	$('#tacos_quantity_selector').click(function(){
		sum_type = "quantity";
		item_sales_get_category_breakdown();
	});

	$('#p42_net_sales_selector').click(function(){
		sum_type = "net_price";
		item_sales_get_category_breakdown();
	});

	$('#p42_quantity_selector').click(function(){
		sum_type = "quantity";
		item_sales_get_category_breakdown();
	});

	/* end click handler for quantity/net price */
}