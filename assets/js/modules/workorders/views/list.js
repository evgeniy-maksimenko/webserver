define([

	'backbone',
	'underscore',
	'modules/workorders/collections/orders',
	'modules/workorders/views/item',
	'layouts/layoutBasic/layout',
	'text!modules/workorders/templates/listTemplate.html',
	'router',

],function(Backbone, _, OrdersCollection, OrderView, Layout, listTemplate, router) {
	
	var DEF_STATUS 		= 'WORK';
	var CLOSED_STATUS   = 'CLOSED';
	
    function prepareHistoryPage() {
        $('.input-daterange').datepicker({
            format: "dd.mm.yyyy",
            language: "ru",
            todayBtn: "linked",
            autoclose: true,
            todayHighlight: true,
            startDate: '-1m',
            endDate: '+0d'
        }).on('hide', function(e) {
            if (e.target.id === "date_to") {
                var startD = new Date();
                var endD = new Date();
                var today = new Date();
                if (startD.getMonth() - 1 < 0) {
                    startD.setMonth(startD.getMonth() - 1 + 12);
                    startD.setFullYear(startD.getFullYear() - 1);
                } else {
                    startD.setMonth(startD.getMonth() - 1);
                }
                if (endD > today) {
                    endD = today;
                }
                $('.input-daterange').datepicker('setStartDate', startD);
                $(e.currentTarget).data('datepicker').pickers[0].setEndDate(endD);
                var curDateMinus7Days = new Date();
                curDateMinus7Days.setDate(curDateMinus7Days.getDate() - 7);
                if (isNaN($(e.currentTarget).data('datepicker').pickers[0].getDate().getMonth())) {
                    $(e.currentTarget).data('datepicker').pickers[0].setDate(curDateMinus7Days);
                }
            }
        });
    }

	function fun_change_order_status() {
		var status = $("#order_status").val();
			if(status == CLOSED_STATUS) {
				$("#form_closed_status").show();
				prepareHistoryPage();
				$("#fromDate").val($.cookie('fromDate'));
				$("#toDate").val($.cookie('toDate'));			
				
			} else {
				$("#form_closed_status").hide();
			}
	}

	function init(this_, status, fromDate, toDate) {
		this_.$el.empty();
		if(fromDate && toDate)
		{
			this_.collection = new OrdersCollection(status, fromDate, toDate);
		} else {
			this_.collection = new OrdersCollection(status);
        }
        this_.collection.fetch({
        	reset:true
        });
        this_.render();
       	this_.listenTo(this_.collection, 'reset', this_.render); 

       	return this_;
	};

	var View1 = Backbone.View.extend({
		 
		template: _.template(listTemplate),

		events: {
			'click #btn_refresh' : 'refresh',
			'change #order_status' : 'change_order_status'
		},

		initialize: function() {			 
			$.removeCookie('status'); 
			init(this, DEF_STATUS);
		},
		render: function() {
			var attrs = router.routeArguments();
			this.$el.html(this.template());
			
			this.collection.each(this.renderOrder, this);
			if(attrs.id) {
				$("#" + attrs.id).click();
			}

			var cookie = $.cookie('status');
			if(cookie) {
				$("#order_status option[value="+cookie+"]").attr('selected', 'selected');
			}
			fun_change_order_status();
			$('.selectpicker').selectpicker();
			return this;
		},
		renderOrder: function(item) {
			var orderView = new OrderView({
            	model: item
	        });
	        $("#orders").append(orderView.render().el);
	        return this;
		},
		refresh: function() {
			var status = $("#order_status").val();
			$.cookie('status', status);
			if( status == CLOSED_STATUS ) {
				var fromDate = $("#fromDate").val();
				var toDate 	 = $("#toDate").val();
				$.cookie('fromDate', fromDate);
				$.cookie('toDate', toDate);
				init(this, status, fromDate, toDate);
			} else {
				init(this, status);
			}
		},
		change_order_status: function() {
			fun_change_order_status();
		}
	});
	
	return Layout.extend({
		content: View1
	});
});
