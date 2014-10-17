

define([], function() {
  	'use strict';
	
	requirejs.config({
		urlArgs: "bust=" + (new Date()).getTime(),
		paths: {
			'jquery' 			    : 'libs/jquery/jquery-1.11.1.min',
			'underscore' 		    : 'libs/underscore/underscore',
			'backbone' 			    : 'libs/backbone/backbone',
			'bootstrap'			    : 'libs/bootstrap/bootstrap.min',
			'bootstrap-select' 	    : 'libs/bootstrap/bootstrap-select.min',
			'backgrid_paginator'	: 'libs/backgrid/backgrid-paginator.min',
			'jquery-cookie'		    : 'libs/jquery/jquery.cookie',
			'jquery-ui'			    : 'libs/jquery/jquery-ui',
			'jquery-color'		    : 'libs/jquery/jquery-color',
			'bootstrap-datepicker' 	: 'libs/bootstrap/bootstrap-datepicker',
			'router' 		        : 'libs/rjs/rjs-router',
			'text' 			        : 'libs/rjs/rjs-text',
			'sweetalert'			: 'libs/sweetalert/sweet-alert.min',
			'alertify'				: 'libs/alertify/alertify.min'
		},

		shim: {
			'backbone' : {
				deps 	: ['jquery', 'underscore','bootstrap','bootstrap-select','jquery-cookie', 'bootstrap-datepicker','jquery-color'],
				exports : 'Backbone'
			}
		}
	});

	require([
		'jquery',
		'router'
	], function($, router) {
		var view;
		router.registerRoutes({
			home: 		            { path: '/', 							moduleId: 'views/home'},
			admin: 		            { path: '/admin', 						moduleId: 'modules/admin/views/index'},
			records:	            { path: '/admin/records', 				moduleId: 'modules/admin/views/records'},
			history:	            { path: '/admin/history', 				moduleId: 'modules/admin/views/history'},
			adm_treatments: 		{ path: '/admin/treatments', 	        moduleId: 'modules/admin/modules/treatments/views/list'},
			adm_static: 			{ path: '/admin/treatments/static', 	moduleId: 'modules/admin/modules/treatments/views/static'},
			adm_static_rgd: 		{ path: '/admin/treatments/static/rgd', moduleId: 'modules/admin/modules/treatments/views/rgd'},
			adm_static_rbd: 		{ path: '/admin/treatments/static/rbd', moduleId: 'modules/admin/modules/treatments/views/rbd'},
			adm_static_res: 		{ path: '/admin/treatments/static/res', moduleId: 'modules/admin/modules/treatments/views/res'},
			adm_users_add: 			{ path: '/admin/users/add', 	    	moduleId: 'modules/admin/modules/users/views/add'},
			adm_users_update: 		{ path: '/admin/users/update/:id', 		moduleId: 'modules/admin/modules/users/views/update'},
			adm_users_index: 		{ path: '/admin/users/index', 			moduleId: 'modules/admin/modules/users/views/index'},
			// ================================================================================================================================	
			adm_treatments_view: 	{ path: '/treatments/edit/:id', 		moduleId: 'modules/admin/modules/treatments/views/edit'},
			recordview:	            { path: '/record/view/:id',				moduleId: 'modules/workorders/modules/record/views/views'},
			sidebar1: 	            { path: '/workorders', 					moduleId: 'modules/workorders/views/list' },
			sidebar2: 	            { path: '/workorders/:id', 				moduleId: 'modules/workorders/views/list' },
			sidebar3:               { path: '/workorders/edit/:id', 		moduleId: 'modules/workorders/views/edit'},
			treatment_f: 		    { path: '/treatment_f', 				moduleId: 'modules/treatments/modules/treatment_f/views/list'},
			treatment_f_edit: 	    { path: '/treatment_f/edit/:id', 		moduleId: 'modules/treatments/modules/treatment_f/views/edit'},
			treatment_s: 		    { path: '/treatment_s', 				moduleId: 'modules/treatments/modules/treatment_s/views/list'},
			treatment_s_edit: 	    { path: '/treatment_s/edit/:id', 		moduleId: 'modules/treatments/modules/treatment_s/views/edit'},
			tm_view_id: 		    { path: '/tm_view/response/:id', 		moduleId: 'modules/treatments/modules/tm_view/views/edit'},
//			sidebar4: 	            { path: '/test', 				    	moduleId: 'modules/workorders/views/test' },
			notFound: 	            { path: '*',					    	moduleId: 'views/notFound'},
		
		}).on('routeload', function onRouteLoad(View, routeArguments) {
			if (view) {
	          view.remove();
	        }
	        view = new View(null, routeArguments);
	        view.render();
	        $('body').append(view.el);
		}).init();
		
	});
	
	
});