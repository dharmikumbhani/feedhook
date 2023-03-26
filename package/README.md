# Feedhook
Register and install the package and start taking attestations the right way.

## Step 1 - Registering your DApp
Go to → [https://feedhook.vercel.app](https://feedhook.vercel.app)
Connect wallet and register with all the following details

## Step 2 - Installing Libraries
Install the library along with dependencies if they aren’t already on the app

```jsx
npm install feedhook
```

Other dependencies

```jsx
npm install wagmi ethers
```

## Step 3 - Add component
Using it in your app

```jsx
import {Feedhook} from 'feedhook';

const YourApp = () => {
	return (
		<>
			<Feedhook widgetType="pageHelpful" callback={callback} />
		</>
	)
}
```

## Step 3 - Add component

Using it in your app

```jsx
import {Feedhook} from 'feedhook';

const YourApp = () => {
	return (
		<>
			<Feedhook widgetType="pageHelpful" callback={callback} />
		</>
	)
}
```
## Step 4 - Add Callback function

```jsx
import {Feedhook} from 'feedhook';

const YourApp = () => {
	const callback = () => {
		// documentation of contract repository
	}
	return (
		<>
			<Feedhook widgetType="pageHelpful" callback={callback} />
		</>
	)
}
```
## API Reference
| Props | Type | Description | Options |
| --- | --- | --- | --- |
| widgetType *required | string | Decide what kind of widget this is? | 1. pageHelpful
2. rateExpereince
3. shareFeedback |
| callback | function |  |  |