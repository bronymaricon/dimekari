window.ellipsize = function(string) {
	var str = string;

	if (str.length > 45)
		str = str.substr(0, 45) + '&hellip;';

	return str;
};

window.ago = function(timestamp) {
	var secs = ((new Date()).getTime() / 1000) - timestamp;
	Math.floor(secs);
	var minutes = secs / 60;
	secs = Math.floor(secs % 60);
	if (minutes < 1) {
		return secs == 1 ? 'Hace un segundo' : 'Hace ' + secs + ' segundos';
	}
	var hours = minutes / 60;
	minutes = Math.floor(minutes % 60);
	if (hours < 1) {
		return minutes == 1 ? 'Hace un minuto' : 'Hace ' + minutes + ' minutos';
	}
	var days = hours / 24;
	hours = Math.floor(hours % 24);
	if (days < 1) {
		return hours == 1 ? 'Hace una hora' : 'Hace ' + hours + ' horas';
	}
	var weeks = days / 7;
	days = Math.floor(days % 7);
	if (weeks < 1) {
		return days == 1 ? 'Ayer' : (days == 2 ? 'Anteayer' : 'Hace ' + days + ' días');
	}
	var months = weeks / 4.35;
	weeks = Math.floor(weeks % 4.35);
	if (months < 1) {
		return weeks == 1 ? 'La semana pasada' : 'Hace ' + weeks + ' semanas';
	}
	var years = months / 12;
	months = Math.floor(months % 12);
	if (years < 1) {
		return months == 1 ? 'El mes pasado' : 'Hace ' + months + ' meses';
	}
	years = Math.floor(years);
	return weeks == 1 ? 'Hace un año' : 'Hace ' + weeks + ' años';
};

window.humanDate = function(timestamp) {
	var date = new Date(timestamp * 1000);
	var month = date.getMonth() + 1,
	    day = date.getDate(),
	    hour = date.getHours(),
	    min = date.getMinutes(),
	    sec = date.getSeconds();

	month = (month < 10 ? '0' : '') + month;
	day = (day < 10 ? '0' : '') + day;
	hour = (hour < 10 ? '0' : '') + hour;
	min = (min < 10 ? '0' : '') + min;
	sec = (sec < 10 ? '0' : '') + sec;

	return date.getFullYear() + '/' + month + '/' + day + ', ' +  hour + ':' + min + ':' + sec;
};

window.formatMessage = function(message, unread) {
	return '<tr data-msgid="' + message.id + '"' + (unread ? ' data-unread="true"' : '') + '><td class="k-message-owner"><img src="//www.taringa.net/avatar.php?user=' + message.sender + '" alt="Avatar">@<a href="//www.taringa.net/' + message.sender + '" target="_blank">' + message.sender + '</a></td><td><a class="k-message-subject" href="#m' + message.id + '">' + message.subject + '</a><span class="k-message-preview">' + ellipsize($('<div></div>').html(message.body).text()) + '</span></td><td><abbr title="' + humanDate(message.date) + '">' + ago(message.date) + '</abbr></td></tr>';
};

window.pushMessage = function(message) {
	var prevScrollTop = $(window).scrollTop();

	$(formatMessage(message, true)).hide().prependTo('#k-message-list').fadeIn();
	window.unreadCount++;
	document.title = '(' + window.unreadCount + ') ' + window.originalTitle;

	if (prevScrollTop > $('#k-message-list').offset().top) {
		$(window).scrollTop(prevScrollTop + $('[data-unread=true]:first').outerHeight());
		$('#k-unread-count').animate({ opacity: 0 }, 250, function() {
			$(this).text(window.unreadCount.toString()).animate({ opacity: 1 }, 250);
		});
		$('#k-unread-bubble > span.k-s')[window.unreadCount == 1 ? 'hide' : 'show']();
		$('#k-unread-bubble').fadeIn();
	}
}

window.showMessage = function(id) {
	window.prevHash = window.location.hash;
	window.location.hash = '#m' + id;
	$('#k-message-avatar').attr('src', '/ms-icon-150x150.png');
	$('#k-message-subject').html("Cargando...");
	$('#k-message-info a').attr('href', '//www.taringa.net/dimekari').text("dimekari");
	$('#k-message-body').html("");
	$('#k-message-info abbr').text("hace 42 años").attr('title', "");
	$('body > .container > .row').addClass('k-blurry');
	$('#k-message-loading').text('Cargando..');
	$('#k-message-loading').fadeIn();
	$('#k-message-view').fadeIn();
	$.ajax({
		url: '//kari.xyz/mp',
		data: { id: id },
		dataType: 'json',
		success: function(data) {
			if (typeof data["error"] !== "undefined"){
				return $('#k-message-loading').text('Algo salió mal.');
			}
			$('#k-message-loading').fadeOut();
			$('#k-message-avatar').attr('src', '//www.taringa.net/avatar.php?user=' + data.sender);
			$('#k-message-subject').html(data.subject);
			$('#k-message-info a').attr('href', '//www.taringa.net/' + data.sender).text(data.sender);
			$('#k-message-info abbr').text(ago(data.date).toLowerCase()).attr('title', humanDate(data.date));
			$('#k-message-body').html(data.body).fadeIn();
		},
		error: function() {
			$('#k-message-loading').text('Algo salió mal.');
		}
	});
}

window.loadMessageList = function(p) {
	if (typeof p !== 'undefined') {
		$('#k-message-list').fadeOut(function() {
			$(this).find('tr:not(#k-empty-box)').remove();
			$(this).fadeIn();
		});
	}

	var page = +p || +($('#k-load-more').data('page') || 0) + 1,
    that = $('#k-load-more');
    that.fadeIn();
	that.data('page', page);
	that.removeClass('k-loading');
	that.addClass('k-loading').html('Cargando&hellip;');

	$("#k-message-list").promise().done(function(){
		$.ajax({
			url: '//kari.xyz/mp/get',
			data: {
				page: page,
				q: window.searchMode ? $('#k-search-box').val() : '',
				t: Date.now()
			},
			dataType: 'json',
			success: function(data) {
				if (typeof data["error"] !== 'undefined') {
					$('#k-empty-box').html('<td colspan="3"><div>Algo salió mal. ¿<a href="#" id="k-retry">Reintentar</a>?</div></td>').fadeIn();
					return;
				}
	
				if (window.searchMode) {
					$('#k-search-count').text(data.matches);
					$('#k-search-count-s')[data.matches === 1 ? 'hide' : 'show']();
					$('#k-search-matches').fadeIn();
				}
	
				if (!data.matches && !$('[data-msgid]').length)
				{
					that.fadeOut();
					return $('#k-empty-box').html('<td colspan="3"><div>No hay nada por aquí&hellip;</div></td>').fadeIn();
				}else{
					$('#k-empty-box').fadeOut();
				}
	
				data.messages.forEach(function(message, index) {
					if (page === 1 && index === 0)
						window.firstMessage = message.id;
	
					if ($('[data-msgid=' + message.id + ']').length)
						return;
					
					$(formatMessage(message)).hide().appendTo('#k-message-list').fadeIn();
				});
				if(data.messages.length == 0){
					that.html('No hay mas mensajes para mostrar');
				}else{
					if (window.searchMode) {
						if(data.matches < 10){
							that.fadeOut();
						}else{
							that.removeClass('k-loading').html('Cargar más&hellip;');
						}
					}else{
						that.removeClass('k-loading').html('Cargar más&hellip;');
					}
				}
			}
		});
	});
};

window.performSearch = function() {
	window.searchMode = true;
	window.unreadCount = 0;
	document.title = window.originalTitle;
	window.location.hash = '#q' + encodeURIComponent($('#k-search-box').val().trim());
	$('#k-unread-bubble, #k-search-matches').fadeOut();
	loadMessageList(1);
}

$(document).ready(function() {
	window.searchMode = false;
	window.unreadCount = 0;
	window.firstMessage = 0;
	window.originalTitle = document.title;
	window.prevHash = '';

	$('#k-unread-bubble, #k-empty-box, #k-message-view, #k-message-loading, #k-message-body, #k-search-matches').hide();

	$('#k-search-box').on('keyup', function(event) {
		var len = $(this).val().trim().length;

		if ((event.keyCode || event.which) === 13 && len) {
			performSearch();
		} else if (!len) {
			window.searchMode = false;
			$('#k-search-matches').fadeOut();

			loadMessageList(1);
		}
	});

	$('#k-message-close').on('click', function() {
		var prevScrollTop = $(window).scrollTop();
		window.location.hash = window.prevHash;
		$(window).scrollTop(prevScrollTop);
		$('#k-message-view').fadeOut();
		$('body > .container > .row').removeClass('k-blurry');
	});

	$('body').on('click', '.k-message-subject', function(event) {
		event.stopPropagation();
		showMessage(+$(this).attr('href').substring(2));
	});
	$(document).click(function(event) {
    	if (!$(event.target).closest('#k-message-view').length) {
        	if ($('#k-message-view').is(":visible")) {
            	var prevScrollTop = $(window).scrollTop();
            	window.location.hash = window.prevHash;
            	$(window).scrollTop(prevScrollTop);
            	$('#k-message-view').fadeOut();
            	$('body > .container > .row').removeClass('k-blurry');
        	}
    	}
	});
	$('body').on('keyup', function(event) {
    	if ((event.keyCode || event.which) === 27) {
        	if ($('#k-message-view').is(":visible")) {
            	var prevScrollTop = $(window).scrollTop();
            	window.location.hash = window.prevHash;
            	$(window).scrollTop(prevScrollTop);
            	$('#k-message-view').fadeOut();
            	$('body > .container > .row').removeClass('k-blurry');
        	}
    	}
	});

	$(window).on('scroll', function() {
		if ($(window).scrollTop() + $(window).height() + 100 >= $('#k-load-more').offset().top) {
			$('#k-load-more').click();
		} else {
			var el = $('[data-unread=true]:first');

			if (el.length && $(window).scrollTop() <= el.offset().top) {
				window.unreadCount = 0;
				document.title = window.originalTitle;
				$('#k-unread-bubble').fadeOut();
			}
		}
	}).scroll();

	$('#k-unread-bubble').on('click', function() {
		$('body').animate({ scrollTop: 0 }, 'fast');
	});

	$('#k-load-more, #k-retry').on('click', function() {
		if ($(this).hasClass('k-loading'))
			return;

		loadMessageList();
	});

	$('#k-search-dismiss').on('click', function() {
		window.searchMode = false;
		window.location.hash = '';
		$('#k-search-box').val('');
		$('#k-search-matches').fadeOut();
		loadMessageList(1);
	});

	setInterval(function() {
		if (window.searchMode)
			return;

		$.ajax({
			url: '//kari.xyz/mp/last',
			data: { id: window.firstMessage, t: Date.now() },
			dataType: 'json',
			success: function(data) {
				if (typeof data["error"] !== 'undefined')
					return;

				data.forEach(function(message) {
					if (message.id > window.firstMessage) {
						pushMessage(message);
						window.firstMessage = message.id;
					}
				});
			}
		});
	}, 5000);

	if (window.location.hash.length > 2) {
		var sub = window.location.hash.substring(0, 2),
		    data = window.location.hash.substring(2);

		if (sub === '#m') {
			showMessage(data);
		} else if (sub === '#q') {
			$('#k-search-box').val(decodeURIComponent(data));
			return performSearch();
		}
	}

	loadMessageList();
});