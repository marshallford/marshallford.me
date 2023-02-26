import SmoothScroll from 'smooth-scroll'
SmoothScroll('a[href*="#more"]')

const asyncWrap = async (promise) => {
  try {
    const result = await promise
    return [result,]
  } catch (err) {
    return [, err]
  }
}

const getConfig = async () => {
  const [res, fetchErr] = await asyncWrap(fetch('/config.json'))
  const [config, jsonErr] = await asyncWrap(res.json())
  return config
}

(async () => {
  const config = await getConfig()
  if(config && config.region) {
    document.querySelector('#region').textContent = config.region
  }
})()
