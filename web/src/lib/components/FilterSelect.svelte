<script lang="ts">
	interface Props {
		options: string[];
		value: string;
		onchange?: (v: string) => void;
		placeholder?: string;
	}

	let { options, value = $bindable(''), onchange, placeholder = 'All' }: Props = $props();

	function handle(e: Event) {
		const v = (e.target as HTMLSelectElement).value;
		value = v;
		onchange?.(v);
	}
</script>

<select
	{value}
	onchange={handle}
	class="w-full rounded border border-border bg-muted px-1 py-0.5 text-xs text-foreground focus:border-primary focus:outline-none"
>
	<option value="">{placeholder}</option>
	{#each options as o (o)}
		<option value={o}>{o}</option>
	{/each}
</select>
