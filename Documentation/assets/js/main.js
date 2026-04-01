/**
 * Documentation Main JavaScript
 * Clean, organized code for better developer understanding
 */

$(document).ready(function() {
    
    /* ===== Mobile Menu Toggle ===== */
    $('.menu-bar, .menubar-icon').on('click', function(e) {
        e.stopPropagation();
        $('nav').toggleClass('open');
        $('body').toggleClass('menu-open');
    });

    // Close menu when clicking outside on mobile
    $(document).on('click', function(e) {
        if ($(window).width() <= 991) {
            if (!$(e.target).closest('nav, .menu-bar, .menubar-icon').length) {
                $('nav').removeClass('open');
                $('body').removeClass('menu-open');
            }
        }
    });

    /* ===== Stickyfill Support ===== */
    // Add browser support to position: sticky for older browsers
    if (typeof Stickyfill !== 'undefined') {
        try {
            var elements = $('.sticky');
            if (elements.length > 0) {
                Stickyfill.add(elements);
            }
        } catch(e) {
            // Stickyfill not available or error
        }
    }
    
    /* ===== Scrollspy Menu Activation ===== */
    // Highlights active menu items based on scroll position
    if ($('#doc-menu').length > 0 && typeof $.fn.scrollspy !== 'undefined') {
        try {
            $('body').scrollspy({
                target: '#doc-menu', 
                offset: 120 
            });
        } catch(e) {
            console.log('Scrollspy not available');
        }
    }
    
    /* ===== Smooth Scrolling ===== */
    // Smooth scroll to sections when clicking navigation links
    $('a.scrollto').on('click', function(e) {
        e.preventDefault();
        var target = $(this.hash);
        
        if (target.length) {
            var targetPosition = target.offset().top;
            targetPosition -= 100; // Account for fixed header

            $('body, html').animate({
                scrollTop: targetPosition
            }, 800);
        }

        // Close mobile menu after navigation
        if ($(window).width() <= 991) {
            $('nav').removeClass('open');
            $('body').removeClass('menu-open');
        }
    });
    
    /* ===== Update Active Menu Item on Scroll ===== */
    $(window).on('scroll', function() {
        updateActiveMenuItem();
    });

    function updateActiveMenuItem() {
        var scrollPos = $(window).scrollTop() + 150;
        
        $('.doc-section').each(function() {
            var top = $(this).offset().top;
            var bottom = top + $(this).outerHeight();
            var id = $(this).attr('id');
            
            if (scrollPos >= top && scrollPos <= bottom) {
                $('.doc-menu .nav-link').removeClass('active');
                $('.doc-menu .nav-link[href="#' + id + '"]').addClass('active');
            }
        });
    }

    /* ===== Collapsible Sections ===== */
    $('.collapsible-header').on('click', function() {
        $(this).toggleClass('expanded');
        $(this).next('.collapsible-content').toggleClass('expanded');
    });

    /* ===== Image Lightbox (if needed) ===== */
    // Uncomment if you want to add image lightbox functionality
    /*
    $(document).delegate('*[data-toggle="lightbox"]', 'click', function(e) {
        e.preventDefault();
        $(this).ekkoLightbox();
    });
    */

    /* ===== Window Resize Handler ===== */
    $(window).on('load resize', function() {
        $(window).trigger('scroll');
        
        // Close mobile menu on resize to desktop
        if ($(window).width() > 991) {
            $('nav').removeClass('open');
            $('body').removeClass('menu-open');
        }
    });

    /* ===== Initialize ===== */
    updateActiveMenuItem();

    /* ===== Search Functionality ===== */
    const searchModal = $('#searchModal');
    const searchTrigger = $('#searchTrigger');
    const searchInput = $('#searchInput');
    const searchResults = $('#searchResults');
    const searchOverlay = $('.search-modal-overlay');

    // Open search modal
    function openSearch() {
        if (searchModal.length === 0) return;
        searchModal.addClass('active');
        setTimeout(() => {
            if (searchInput.length > 0) {
                searchInput.focus();
            }
        }, 100);
        $('body').css('overflow', 'hidden');
    }

    // Close search modal
    function closeSearch() {
        if (searchModal.length === 0) return;
        searchModal.removeClass('active');
        if (searchInput.length > 0) {
            searchInput.val('');
        }
        if (searchResults.length > 0) {
            searchResults.html('<div class="search-empty"><p>Type to search documentation...</p></div>');
        }
        $('body').css('overflow', '');
    }

    // Only initialize search if elements exist
    if (searchModal.length > 0 && searchTrigger.length > 0 && searchInput.length > 0) {

        // Search trigger click
        searchTrigger.on('click', function(e) {
            e.preventDefault();
            openSearch();
        });

        // Close on overlay click
        if (searchOverlay.length > 0) {
            searchOverlay.on('click', function() {
                closeSearch();
            });
        }

        // CMD+K or CTRL+K to open search
        $(document).on('keydown', function(e) {
            // Don't trigger if typing in input/textarea (except search input)
            if ($(e.target).is('input, textarea') && !$(e.target).is('#searchInput')) {
                return;
            }
            
            if ((e.metaKey || e.ctrlKey) && (e.key === 'k' || e.key === 'K')) {
                e.preventDefault();
                if (searchModal.length > 0 && searchModal.hasClass('active')) {
                    closeSearch();
                } else {
                    openSearch();
                }
            }
            if (e.key === 'Escape' && searchModal.length > 0 && searchModal.hasClass('active')) {
                closeSearch();
            }
        });
    }

    // Search functionality
    let searchIndex = [];
    let isIndexing = false;
    
    // Determine current page
    function getCurrentPage() {
        const currentPath = window.location.pathname;
        const currentHref = window.location.href;
        
        // Check if we're on Flutter docs page
        if (currentPath.includes('flutterDocs.html') || currentPath.includes('flutterDocs') || 
            currentHref.includes('flutterDocs.html') || currentHref.includes('flutterDocs')) {
            return { 
                name: 'Flutter', 
                url: './assets/flutterDocs.html', 
                otherUrl: '../index.html',
                otherName: 'Admin Panel'
            };
        } else {
            return { 
                name: 'Admin Panel', 
                url: './index.html', 
                otherUrl: './assets/flutterDocs.html',
                otherName: 'Flutter'
            };
        }
    }
    
    // Index a single section
    function indexSection($section, pageInfo) {
        const id = $section.attr('id');
        const title = $section.find('h2.section-title, .section-title, h2').first().text().trim();
        
        if (!id || !title) return null;
        
        // Get comprehensive content from the section
        let fullContent = '';
        
        // Get text from paragraphs
        $section.find('p, .lead').each(function() {
            fullContent += $(this).text().trim() + ' ';
        });
        
        // Get text from list items
        $section.find('li').each(function() {
            fullContent += $(this).text().trim() + ' ';
        });
        
        // Get text from headings (h3, h4)
        $section.find('h3, h4').each(function() {
            fullContent += $(this).text().trim() + ' ';
        });
        
        // Get text from code blocks (first 300 chars)
        $section.find('code').each(function() {
            fullContent += $(this).text().trim().substring(0, 300) + ' ';
        });
        
        // Get text from info boxes
        $section.find('.info-box-content').each(function() {
            fullContent += $(this).text().trim() + ' ';
        });
        
        // If no structured content found, get all text
        if (!fullContent.trim()) {
            fullContent = $section.text();
        }
        
        // Clean up content (remove extra whitespace, limit length)
        fullContent = fullContent.replace(/\s+/g, ' ').trim().substring(0, 1000);
        
        // Try to find nav link (works for current page, will be empty for other page)
        const navLink = $(`.nav-link[href="#${id}"]`);
        
        return {
            id: id,
            title: title,
            content: fullContent,
            navText: navLink.length ? navLink.text().trim() : title,
            page: pageInfo.name,
            pageUrl: pageInfo.url
        };
    }
    
    // Build search index from all sections
    function buildSearchIndex() {
        if (isIndexing) return;
        isIndexing = true;
        searchIndex = [];
        
        const currentPage = getCurrentPage();
        
        // Index current page sections
        $('.doc-section').each(function() {
            const indexed = indexSection($(this), currentPage);
            if (indexed) {
                searchIndex.push(indexed);
            }
        });

        // Add individual headings from current page
        $('.doc-section h3, .doc-section h4').each(function() {
            const $heading = $(this);
            const title = $heading.text().trim();
            const $section = $heading.closest('.doc-section');
            const sectionId = $section.attr('id');
            
            if (!title || !sectionId) return;
            
            let headingContent = '';
            $heading.nextUntil('h2, h3, h4').each(function() {
                const $elem = $(this);
                if ($elem.is('p, li, .lead, .info-box-content')) {
                    headingContent += $elem.text().trim() + ' ';
                } else if ($elem.find('p, li').length) {
                    headingContent += $elem.find('p, li').text().trim() + ' ';
                }
            });
            
            headingContent = headingContent.replace(/\s+/g, ' ').trim().substring(0, 500);
            
            if (headingContent.length > 20) {
                searchIndex.push({
                    id: sectionId,
                    title: title,
                    content: headingContent,
                    navText: title,
                    page: currentPage.name,
                    pageUrl: currentPage.url
                });
            }
        });
        
        // Add list items from current page
        $('.doc-section .list-section li').each(function() {
            const $li = $(this);
            const text = $li.text().trim();
            const $section = $li.closest('.doc-section');
            const sectionId = $section.attr('id');
            const sectionTitle = $section.find('h2.section-title, .section-title, h2').first().text().trim();
            
            if (text.length > 30 && sectionId && sectionTitle) {
                const $parentHeading = $li.closest('.doc-section').find('h3, h4').last();
                const parentTitle = $parentHeading.length ? $parentHeading.text().trim() : sectionTitle;
                
                searchIndex.push({
                    id: sectionId,
                    title: parentTitle + ' - ' + text.substring(0, 60) + (text.length > 60 ? '...' : ''),
                    content: text,
                    navText: parentTitle,
                    page: currentPage.name,
                    pageUrl: currentPage.url
                });
            }
        });
        
        // Fetch and index the other page
        const otherPageInfo = {
            name: currentPage.otherName,
            url: currentPage.otherUrl
        };
        fetchOtherPage(currentPage.otherUrl, otherPageInfo);
    }
    
    // Fetch and index content from the other page
    function fetchOtherPage(url, pageInfo) {
        console.log('Fetching other page:', url, 'for', pageInfo.name);
        $.ajax({
            url: url,
            method: 'GET',
            dataType: 'html',
            success: function(html) {
                console.log('Successfully loaded other page:', pageInfo.name);
                const $otherPage = $(html);
                
                // Index sections from other page
                $otherPage.find('.doc-section').each(function() {
                    const indexed = indexSection($(this), pageInfo);
                    if (indexed) {
                        searchIndex.push(indexed);
                    }
                });
                
                // Index headings from other page
                $otherPage.find('.doc-section h3, .doc-section h4').each(function() {
                    const $heading = $(this);
                    const title = $heading.text().trim();
                    const $section = $heading.closest('.doc-section');
                    const sectionId = $section.attr('id');
                    
                    if (!title || !sectionId) return;
                    
                    let headingContent = '';
                    $heading.nextUntil('h2, h3, h4').each(function() {
                        const $elem = $(this);
                        if ($elem.is('p, li, .lead, .info-box-content')) {
                            headingContent += $elem.text().trim() + ' ';
                        } else if ($elem.find('p, li').length) {
                            headingContent += $elem.find('p, li').text().trim() + ' ';
                        }
                    });
                    
                    headingContent = headingContent.replace(/\s+/g, ' ').trim().substring(0, 500);
                    
                    if (headingContent.length > 20) {
                        searchIndex.push({
                            id: sectionId,
                            title: title,
                            content: headingContent,
                            navText: title,
                            page: pageInfo.name,
                            pageUrl: pageInfo.url
                        });
                    }
                });
                
                // Index list items from other page
                $otherPage.find('.doc-section .list-section li').each(function() {
                    const $li = $(this);
                    const text = $li.text().trim();
                    const $section = $li.closest('.doc-section');
                    const sectionId = $section.attr('id');
                    const sectionTitle = $section.find('h2.section-title, .section-title, h2').first().text().trim();
                    
                    if (text.length > 30 && sectionId && sectionTitle) {
                        const $parentHeading = $li.closest('.doc-section').find('h3, h4').last();
                        const parentTitle = $parentHeading.length ? $parentHeading.text().trim() : sectionTitle;
                        
                        searchIndex.push({
                            id: sectionId,
                            title: parentTitle + ' - ' + text.substring(0, 60) + (text.length > 60 ? '...' : ''),
                            content: text,
                            navText: parentTitle,
                            page: pageInfo.name,
                            pageUrl: pageInfo.url
                        });
                    }
                });
                
                const totalItems = searchIndex.length;
                const currentPageItems = searchIndex.filter(item => item.page === getCurrentPage().name).length;
                const otherPageItems = totalItems - currentPageItems;
                
                console.log(`Indexed ${totalItems} total items: ${currentPageItems} from current page, ${otherPageItems} from other page`);
                isIndexing = false;
                
                // If search is active, re-run it to include new results
                const currentQuery = searchInput.val();
                if (currentQuery && currentQuery.length >= 2) {
                    performSearch(currentQuery);
                }
            },
            error: function(xhr, status, error) {
                console.log('Could not load other page for search indexing:', url, error);
                // Still allow search to work with current page only
                isIndexing = false;
            }
        });
    }
    

    // Perform search with scoring
    function performSearch(query) {
        if (!searchResults || searchResults.length === 0) return;
        if (!query || query.length < 2) {
            searchResults.html('<div class="search-empty"><p>Type to search documentation...</p></div>');
            return;
        }

        // Check if we have items from both pages
        const currentPage = getCurrentPage();
        const currentPageItems = searchIndex.filter(item => item.page === currentPage.name);
        const otherPageItems = searchIndex.filter(item => item.page !== currentPage.name);
        
        // Show loading message if other page is still being indexed
        if (isIndexing && otherPageItems.length === 0) {
            searchResults.html('<div class="search-empty"><p>Loading content from both pages... Results will update automatically.</p></div>');
        }

        const lowerQuery = query.toLowerCase();
        const queryWords = lowerQuery.split(/\s+/).filter(w => w.length > 0);
        
        // Score and filter results from BOTH pages
        const scoredResults = searchIndex.map(item => {
            let score = 0;
            const lowerTitle = item.title.toLowerCase();
            const lowerContent = item.content.toLowerCase();
            const lowerNavText = item.navText.toLowerCase();
            
            // Title matches get highest score
            queryWords.forEach(word => {
                if (lowerTitle.includes(word)) {
                    if (lowerTitle.startsWith(word)) score += 10;
                    else if (lowerTitle.indexOf(' ' + word) !== -1) score += 8;
                    else score += 5;
                }
                
                // Content matches
                if (lowerContent.includes(word)) {
                    const position = lowerContent.indexOf(word);
                    // Earlier in content = higher score
                    score += Math.max(1, 5 - Math.floor(position / 100));
                }
                
                // Nav text matches
                if (lowerNavText.includes(word)) {
                    score += 3;
                }
            });
            
            return { ...item, score };
        }).filter(item => item.score > 0)
          .sort((a, b) => b.score - a.score);

        if (scoredResults.length === 0) {
            if (searchResults && searchResults.length > 0) {
                const hasOtherPage = searchIndex.some(item => item.page !== currentPage.name);
                let message = 'No results found. Try a different search term.';
                if (!hasOtherPage && !isIndexing) {
                    message += ' (Searching both Admin Panel and Flutter docs)';
                }
                searchResults.html('<div class="search-empty"><p>' + message + '</p></div>');
            }
            return;
        }

        // Count results from each page
        const resultsFromCurrent = scoredResults.filter(r => r.page === currentPage.name).length;
        const resultsFromOther = scoredResults.filter(r => r.page !== currentPage.name).length;
        
        let resultsHtml = '';
        
        // Add summary header if we have results from both pages
        if (resultsFromCurrent > 0 && resultsFromOther > 0) {
            resultsHtml += `<div class="search-results-summary">
                <span>Found ${scoredResults.length} results: ${resultsFromCurrent} from ${currentPage.name}, ${resultsFromOther} from ${currentPage.otherName}</span>
            </div>`;
        }
        
        scoredResults.slice(0, 15).forEach((result, index) => {
            const isActive = index === 0 ? 'active' : '';
            
            // Get snippet from content that contains the query
            let snippet = result.content.substring(0, 120);
            const queryIndex = result.content.toLowerCase().indexOf(lowerQuery);
            if (queryIndex !== -1) {
                const start = Math.max(0, queryIndex - 40);
                const end = Math.min(result.content.length, queryIndex + lowerQuery.length + 80);
                snippet = result.content.substring(start, end);
                if (start > 0) snippet = '...' + snippet;
                if (end < result.content.length) snippet = snippet + '...';
            }
            
            const currentPage = getCurrentPage();
            const isOtherPage = result.page !== currentPage.name;
            const resultUrl = isOtherPage ? result.pageUrl + '#' + result.id : '#' + result.id;
            
            resultsHtml += `
                <div class="search-result-item ${isActive}" data-href="${resultUrl}" data-page="${result.page}">
                    <div class="search-result-header">
                        <div class="search-result-title">${highlightText(result.title, query)}</div>
                        <span class="search-result-badge ${isOtherPage ? 'badge-other' : 'badge-current'}">${result.page}</span>
                    </div>
                    <div class="search-result-snippet">${highlightText(snippet, query)}</div>
                    <div class="search-result-path">${result.navText}</div>
                </div>
            `;
        });

        if (searchResults && searchResults.length > 0) {
            searchResults.html(resultsHtml);
        }

        // Handle result clicks
        $(document).off('click', '.search-result-item').on('click', '.search-result-item', function() {
            const href = $(this).data('href');
            const page = $(this).data('page');
            const currentPage = getCurrentPage();
            
            if (href) {
                if (typeof closeSearch === 'function') {
                    closeSearch();
                }
                
                // If it's from another page, navigate to that page first
                if (page && page !== currentPage.name) {
                    // Navigate to the other page
                    window.location.href = href;
                } else {
                    // Same page, just scroll
                    if (href.startsWith('#')) {
                        const target = $(href);
                        if (target.length) {
                            $('html, body').animate({
                                scrollTop: target.offset().top - 100
                            }, 500);
                            $(`.nav-link[href="${href}"]`).addClass('active');
                        }
                    } else {
                        window.location.href = href;
                    }
                }
            }
        });
    }

    // Highlight search text (handles multiple words)
    function highlightText(text, query) {
        if (!text) return '';
        // Escape special regex characters
        const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        // Split query into words and create regex
        const words = escapedQuery.split(/\s+/).filter(w => w.length > 0);
        let highlighted = text;
        
        words.forEach(word => {
            const regex = new RegExp(`(${word})`, 'gi');
            highlighted = highlighted.replace(regex, '<mark>$1</mark>');
        });
        
        return highlighted;
    }

    // Search input handler (only if search input exists)
    if (searchInput.length > 0) {
        let searchTimeout;
        searchInput.on('input', function() {
            clearTimeout(searchTimeout);
            const query = $(this).val();
            searchTimeout = setTimeout(() => {
                if (typeof performSearch === 'function') {
                    performSearch(query);
                }
            }, 200);
        });

        // Keyboard navigation in search results
        let selectedIndex = 0;
        searchInput.on('keydown', function(e) {
            // Don't interfere with CMD+K
            if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
                return;
            }
            
            const items = $('.search-result-item');
            if (items.length === 0) return;

            if (e.key === 'ArrowDown') {
                e.preventDefault();
                selectedIndex = Math.min(selectedIndex + 1, items.length - 1);
                items.removeClass('active').eq(selectedIndex).addClass('active');
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                selectedIndex = Math.max(selectedIndex - 1, 0);
                items.removeClass('active').eq(selectedIndex).addClass('active');
            } else if (e.key === 'Enter') {
                e.preventDefault();
                const activeItem = items.filter('.active');
                if (activeItem.length) {
                    activeItem.click();
                } else if (items.length > 0) {
                    // Click first item if none selected
                    items.first().click();
                }
            }
        });
    }

    // Build search index on page load
    buildSearchIndex();

    /* ===== Theme Toggle ===== */
    const themeToggle = $('#themeToggle');
    const currentTheme = localStorage.getItem('theme') || 'light';

    // Apply saved theme
    if (currentTheme === 'dark') {
        $('html').attr('data-theme', 'dark');
    }

    // Toggle theme
    themeToggle.on('click', function() {
        const html = $('html');
        const currentTheme = html.attr('data-theme');
        
        if (currentTheme === 'dark') {
            html.attr('data-theme', 'light');
            localStorage.setItem('theme', 'light');
        } else {
            html.attr('data-theme', 'dark');
            localStorage.setItem('theme', 'dark');
        }
    });
});
