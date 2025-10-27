/**
 * Throttle function execution to at most once per specified interval
 *
 * @param {Function} func - Function to throttle
 * @param {number} wait - Milliseconds to wait between executions
 * @returns {Function} Throttled function
 *
 * @example
 * const throttledResize = throttle(handleResize, 150)
 * window.addEventListener('resize', throttledResize)
 */
export function throttle(func, wait = 150) {
  let timeout = null
  let lastRan = null

  return function executedFunction(...args) {
    const context = this

    if (!lastRan) {
      // First call - execute immediately
      func.apply(context, args)
      lastRan = Date.now()
    } else {
      // Clear any pending timeout
      clearTimeout(timeout)

      // Schedule next execution
      timeout = setTimeout(() => {
        if (Date.now() - lastRan >= wait) {
          func.apply(context, args)
          lastRan = Date.now()
        }
      }, wait - (Date.now() - lastRan))
    }
  }
}

/**
 * Debounce function execution to wait until function stops being called
 *
 * @param {Function} func - Function to debounce
 * @param {number} wait - Milliseconds to wait
 * @returns {Function} Debounced function
 */
export function debounce(func, wait = 150) {
  let timeout

  return function executedFunction(...args) {
    const context = this

    clearTimeout(timeout)
    timeout = setTimeout(() => func.apply(context, args), wait)
  }
}
