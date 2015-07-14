<p>
	This script downloads wallpapers from <a href="http://alpha.wallhaven.cc" target="_blank">wallhaven.cc</a>, the script offers various filter options to download only wallpapers to your liking.
	<br/>
	Right now <a href="http://alpha.wallhaven.cc" target="_blank">wallhaven.cc</a> is still in Alpha so dont expect too many updates until it hits at least Beta Status.
	<br />
</p>

<p>
	<h3>This Script is written for GNU Linux, it should work under Mac OS</h3>
	<br />
</p>

<p>
	<strong>Changelog :</strong>
	<ul>
		<li>
			<strong>Revision 0.1.6.4</strong><br />
			<ol>
				<li>added a starting page number (by ry167)</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.6.3</strong><br />
			<ol>
				<li>added -m 1 option to grep command to prevent downloading every wallpaper twice</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.6.2</strong><br />
			<ol>
				<li>sorting variable now affects search results, thanks to munhyunsu for pointing it out</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.6.1</strong><br />
			<ol>
				<li>added http prefix to referer</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.6</strong><br />
			<ol>
				<li>fixed issue with login token</li>
				<li>added useragent to wget to fix "403 forbidden" error</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.5</strong><br />
			<ol>
				<li>fixed issue if all wallpapers on a page where already downloaded</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.4</strong><br />
			<ol>
				<li>fixed parallel mode</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.3</strong><br />
			<ol>
				<li>added check if downloaded.txt file exists</li>
				<li>added "--gnu" option to parallel<br />
				(for some older Distributions which set the default mode to tollef) <br />
				For some older Versions of parallel remove the "--no-notice" option if you get an error like this: <br />
				"parallel: Error: Command (--no-notice) starts with '-'. Is this a wrong option?"</li>
				<li>fixed issue where wget would not automatically add a "http://" prefix</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.2</strong><br />
			<ol>
				<li>fixed urls to work with latest wallhaven update</li>
				<li>added some comments</li>
				<li>fixed login issue when downloading favorites</li>
				<li>merged normal and parallel version</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1.1</strong><br />
			<ol>
				<li>updated and tested parts of the script to work with newest wallhaven site (not all features tested)</li>
			</ol>
		</li>
		<li>
			<strong>Revision 0.1</strong><br />
			<ol>
				<li>first Version of script, most features from the wallbase script are implemented</li>
			</ol>
		</li>
	</ul>
</p>