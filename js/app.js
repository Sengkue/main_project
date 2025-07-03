// Page navigation
function showPage(pageId) {
    // Hide all pages
    const pages = document.querySelectorAll('.page-content');
    pages.forEach(page => page.classList.remove('active'));

    // Show selected page
    const selectedPage = document.getElementById(pageId + '-page');
    if (selectedPage) {
        selectedPage.classList.add('active');
        selectedPage.classList.add('fade-in');
        
        // Remove animation class after animation completes
        setTimeout(() => {
            selectedPage.classList.remove('fade-in');
        }, 600);
    }

    // Update active menu item
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => link.classList.remove('active'));
    
    const activeLink = document.querySelector(`[onclick="showPage('${pageId}')"]`);
    if (activeLink) {
        activeLink.classList.add('active');
    }

    // Update header
    updateHeader(pageId);

    // Close mobile menu
    closeMobileMenu();
}

function updateHeader(pageId) {
    const titles = {
        'dashboard': 'ຍິນດີຕ້ອນຮັບສູ່ແດຊບອດຫຼັກ',
        'heartbreak': '💔 ກຳລັງໃຈສຳລັບໃຈທີ່ແຕກສະຫຼາຍ',
        'wellness': '🧘‍♀️ ສຸຂະພາບຈິດ',
        'motivation': '💪 ແຮງບັນດານໃຈ',
        'community': '👥 ຊຸມຊົນ',
        'resources': '📚 ແຫຼ່ງຂໍ້ມູນ',
        'settings': '⚙️ ການຕັ້ງຄ່າ'
    };

    const breadcrumbs = {
        'dashboard': 'ໜ້າຫຼັກ / ແດຊບອດ',
        'heartbreak': 'ໜ້າຫຼັກ / ກຳລັງໃຈໃຈແຕກ',
        'wellness': 'ໜ້າຫຼັກ / ສຸຂະພາບຈິດ',
        'motivation': 'ໜ້າຫຼັກ / ແຮງບັນດານໃຈ',
        'community': 'ໜ້າຫຼັກ / ຊຸມຊົນ',
        'resources': 'ໜ້າຫຼັກ / ແຫຼ່ງຂໍ້ມູນ',
        'settings': 'ໜ້າຫຼັກ / ການຕັ້ງຄ່າ'
    };

    document.getElementById('page-title').textContent = titles[pageId] || titles['dashboard'];
    document.getElementById('breadcrumb').textContent = breadcrumbs[pageId] || breadcrumbs['dashboard'];
}

// Sidebar toggle
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('collapsed');
    
    const toggleBtn = document.querySelector('.menu-toggle');
    if (sidebar.classList.contains('collapsed')) {
        toggleBtn.innerHTML = '▶';
    } else {
        toggleBtn.innerHTML = '◀';
    }
}

// Mobile menu toggle
function toggleMobileMenu() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('mobile-open');
}

function closeMobileMenu() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.remove('mobile-open');
}

// Utility functions
function animateNumber(element, start, end, duration) {
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        const current = Math.floor(progress * (end - start) + start);
        element.textContent = current + (end > 99 ? '+' : '');
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
}

// Initialize stats animation
function initStatsAnimation() {
    const statNumbers = document.querySelectorAll('.stat-number');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const target = entry.target;
                const text = target.textContent;
                const number = parseInt(text.replace(/[^0-9]/g, ''));
                target.textContent = '0';
                animateNumber(target, 0, number, 2000);
                observer.unobserve(target);
            }
        });
    });

    statNumbers.forEach(number => {
        observer.observe(number);
    });
}

// Theme switching function
function toggleTheme() {
    const body = document.body;
    body.classList.toggle('dark-theme');
    
    // Save theme preference
    const isDark = body.classList.contains('dark-theme');
    localStorage.setItem('darkTheme', isDark);
}

// Load saved theme
function loadTheme() {
    const savedTheme = localStorage.getItem('darkTheme');
    if (savedTheme === 'true') {
        document.body.classList.add('dark-theme');
    }
}

// Smooth scroll function
function smoothScrollTo(element) {
    element.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
    });
}

// Add loading state to cards
function addLoadingState(element) {
    element.classList.add('loading');
    setTimeout(() => {
        element.classList.remove('loading');
    }, 1000);
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // Show dashboard by default
    showPage('dashboard');
    
    // Load saved theme
    loadTheme();
    
    // Initialize stats animation
    initStatsAnimation();
    
    // Add click effects to dashboard cards
    const dashboardCards = document.querySelectorAll('.dashboard-card');
    dashboardCards.forEach(card => {
        card.addEventListener('click', function() {
            addLoadingState(this);
        });
    });
});

// Close mobile menu when clicking outside
document.addEventListener('click', function(e) {
    const sidebar = document.getElementById('sidebar');
    const menuBtn = document.querySelector('.mobile-menu-btn');
    
    if (window.innerWidth <= 768 && 
        !sidebar.contains(e.target) && 
        !menuBtn.contains(e.target)) {
        closeMobileMenu();
    }
});

// Handle window resize
window.addEventListener('resize', function() {
    const sidebar = document.getElementById('sidebar');
    if (window.innerWidth > 768) {
        sidebar.classList.remove('mobile-open');
    }
});

// Keyboard navigation
document.addEventListener('keydown', function(e) {
    // ESC key to close mobile menu
    if (e.key === 'Escape') {
        closeMobileMenu();
    }
    
    // Alt + M to toggle mobile menu
    if (e.altKey && e.key === 'm') {
        e.preventDefault();
        toggleMobileMenu();
    }
    
    // Alt + S to toggle sidebar
    if (e.altKey && e.key === 's') {
        e.preventDefault();
        toggleSidebar();
    }
});

// Performance optimization: Lazy load iframes
function lazyLoadIframes() {
    const iframes = document.querySelectorAll('iframe');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const iframe = entry.target;
                if (!iframe.src && iframe.dataset.src) {
                    iframe.src = iframe.dataset.src;
                }
                observer.unobserve(iframe);
            }
        });
    });

    iframes.forEach(iframe => {
        observer.observe(iframe);
    });
}

// Initialize lazy loading
document.addEventListener('DOMContentLoaded', lazyLoadIframes);