define([
	'backbone',
	'layouts/layoutAdmin/layout',
	'text!modules/admin/templates/historyTemplate.html',
	'modules/admin/views/history_',
	'modules/admin/collections/history',
	'router',

], function(Backbone, Layout, historyTemplate, HistoryView, HistoryCollection, router) {

	    function prepareHistoryPage() {
        $('.input-daterange').datepicker({
            format: "yyyy-mm-dd",
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


	var HistoryPage = Backbone.View.extend({

		template: _.template(historyTemplate),

        events: {
            'click #btn_refresh' : 'refresh_records'
        },

        filtered: function(date_from, date_to) {
            if(date_from && date_to)
            {
                this.collection = new HistoryCollection(date_from, date_to);
            }
            else
            {
                this.collection = new HistoryCollection();
            }
            this.collection.fetch({
                reset:true
            });
            this.listenTo(this.collection, 'reset', this.render); 
            return this;
        },
		initialize: function() {
            $.removeCookie('fromDate');
            $.removeCookie('toDate');
            this.filtered();
            return this;
		},
		render: function() {
			var attrs = router.routeArguments();
			this.$el.html(this.template(this));            

            prepareHistoryPage();
            
            $("#date_from").val($.cookie('fromDate'));
            $("#date_to").val($.cookie('toDate'));

            $("#count").html(this.collection.length);
            
            this.collection.each(this.renderOrder, this);
			return this;
		},
		renderOrder: function(item) {
			var historyView = new HistoryView({
            	model: item
	        });
	        $("#history").append(historyView.render().el);
	        return this;
		},

        refresh_records: function() {
            var fromDate = $("#date_from").val();
            var toDate   = $("#date_to").val();
            
            $.cookie('fromDate', fromDate);
            $.cookie('toDate', toDate);

            this.filtered(fromDate, toDate);
        }
	});

	return Layout.extend({
		content: HistoryPage
	})
});