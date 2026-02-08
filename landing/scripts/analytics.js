// Rilo Landing Page Analytics
// Replace G-XXXXXXXXXX with your actual GA4 Measurement ID

// Initialize GA4 (uncomment when you have your ID)
// window.dataLayer = window.dataLayer || [];
// function gtag(){dataLayer.push(arguments);}
// gtag('js', new Date());
// gtag('config', 'G-XXXXXXXXXX', {
//   'send_page_view': true,
//   'anonymize_ip': true
// });

// For now, use console logging for development
const isDev = window.location.hostname === 'localhost' || window.location.hostname.includes('vercel.app');

function logEvent(eventName, params = {}) {
  if (isDev) {
    console.log(`[Analytics] ${eventName}`, params);
  }

  // Uncomment when GA4 is set up
  // if (typeof gtag !== 'undefined') {
  //   gtag('event', eventName, params);
  // }
}

// Track email signup
function trackSignup(source) {
  logEvent('generate_lead', {
    'event_category': 'engagement',
    'event_label': source,
    'value': 1
  });
}

// Track "See pricing" clicks (WTP signal)
function trackPricingIntent() {
  logEvent('view_item', {
    'event_category': 'wtp_signal',
    'event_label': 'pricing_click',
    'value': 1
  });

  // Show a simple alert for now since there's no pricing page yet
  alert('Pricing coming soon! Sign up to get early access pricing.');
}

// Track Spending Roast interest
function trackRoastInterest() {
  logEvent('select_content', {
    'event_category': 'feature_interest',
    'event_label': 'spending_roast',
    'value': 1
  });
}

// Scroll depth tracking
const scrollMilestones = [25, 50, 75, 100];
const scrolledMilestones = new Set();

function trackScrollDepth() {
  const scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
  if (scrollHeight <= 0) return;

  const scrollPercent = Math.round((window.scrollY / scrollHeight) * 100);

  scrollMilestones.forEach(milestone => {
    if (scrollPercent >= milestone && !scrolledMilestones.has(milestone)) {
      scrolledMilestones.add(milestone);
      logEvent('scroll', {
        'event_category': 'engagement',
        'event_label': `${milestone}%`,
        'value': milestone
      });
    }
  });
}

// Throttle scroll events
let scrollTimeout;
window.addEventListener('scroll', () => {
  if (scrollTimeout) return;
  scrollTimeout = setTimeout(() => {
    trackScrollDepth();
    scrollTimeout = null;
  }, 100);
});

// Track time on page
let pageLoadTime = Date.now();

window.addEventListener('beforeunload', () => {
  const timeOnPage = Math.round((Date.now() - pageLoadTime) / 1000);
  logEvent('timing_complete', {
    'event_category': 'engagement',
    'event_label': 'time_on_page',
    'value': timeOnPage
  });
});

// Log page view on load
document.addEventListener('DOMContentLoaded', () => {
  logEvent('page_view', {
    'page_title': document.title,
    'page_location': window.location.href
  });
});
