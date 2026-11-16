---
id:            SEED-DRAFT-chartingplatform
title:         "Market Monitoring and Alerts: Charting Platforms as Prior Art"
genre:         Eval
subtype:       prior-art
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0012
  - SEED-0009
  - SEED-0010
  - SEED-0006
  - SEED-0008
  - SEED-0001
  - VOX-DRAFT-vox
cites:
  - title:     "Exact: Essential eXpression Articulating Coherent Topology"
    locator:   "~/src/chat/Exact.md"
    external:  true
  - title:     "Will alerts work if TradingView is not open on the computer?"
    locator:   "TradingView support, https://www.tradingview.com/support/solutions/43000548327/ (consulted November 2026)"
    external:  true
  - title:     "Getting started with technical alerts"
    locator:   "TradingView support, https://www.tradingview.com/support/solutions/43000763315/ (consulted November 2026)"
    external:  true
  - title:     "How to set up alerts"
    locator:   "TradingView support, https://www.tradingview.com/support/solutions/43000595315/ (consulted November 2026)"
    external:  true
  - title:     "How to configure webhook alerts"
    locator:   "TradingView support, https://www.tradingview.com/support/solutions/43000529348/ (consulted November 2026)"
    external:  true
  - title:     "Rules of Using the Virtual Hosting Service"
    locator:   "MetaQuotes, https://www.mql5.com/en/vps/rules (consulted November 2026)"
    external:  true
  - title:     "Configuring Alerts"
    locator:   "NinjaTrader 8 Help Guide, https://static.ninjatrader.com/support/helpGuides/nt8/configuring_alerts.htm (consulted November 2026)"
    external:  true
  - title:     "Automate Futures Trading in NinjaTrader — No Coding Required"
    locator:   "NinjaTrader blog, https://ninjatrader.com/futures/blogs/automating-your-trading-strategy-with-alerts/ (November 2025)"
    external:  true
  - title:     "Keep alerts active under instrument link"
    locator:   "NinjaTrader support forum, https://forum.ninjatrader.com/forum/ninjatrader-8/add-on-development/101620 (September 2017)"
    external:  true
  - title:     "NinjaTrader 8 Drawing Tools and Alerts"
    locator:   "Way of the Trader, https://wayofthetrader.com/education/tools/ninjatrader-8-drawing-tools-alerts (September 2026)"
    external:  true
  - title:     "Alerts"
    locator:   "MotiveWave Docs, https://docs.motivewave.com/user-guide/alerts (consulted November 2026)"
    external:  true
  - title:     "Alert preferences"
    locator:   "MotiveWave Docs, https://docs.motivewave.com/user-guide/console-1/settings/alerts (consulted November 2026)"
    external:  true
  - title:     "Strategies (SDK Programming Guide)"
    locator:   "MotiveWave Docs, https://docs.motivewave.com/user-guide/sdk-programming-guide/strategies (consulted November 2026)"
    external:  true
  - title:     "Compare editions"
    locator:   "MotiveWave, https://www.motivewave.com/products/compare-editions.htm (consulted November 2026)"
    external:  true
  - title:     "Automatic trading — ProOrder AutoTrading"
    locator:   "ProRealTime, https://www.prorealtime.com/en/auto-trading (consulted November 2026)"
    external:  true
  - title:     "Conditions of Execution of Automatic Trading Systems"
    locator:   "ProRealTime, https://trading.prorealtime.com/en/automatic-trading-conditions (consulted November 2026)"
    external:  true
  - title:     "What Is ProOrder? Automated Trading in ProRealTime with IG"
    locator:   "A+ Algos, https://www.aplusalgos.com/blogs/learn/prorealtime-proorder-automated-trading (updated October 2026)"
    external:  true
  - title:     "ProOrder AutoTrading quick guide"
    locator:   "IG Securities (Japan), https://a.c-dn.net/c/content/dam/publicsites/1466049315736/igcom/jp/files/ig-services/ProOrder-quick_guide.pdf"
    external:  true
  - title:     "TradingView alerts: create, configure and automate"
    locator:   "TheConnector, https://theconnector.fr/en/tradingview-alerts (consulted November 2026)"
    external:  true
  - title:     "Manage alerts"
    locator:   "TradingView support, https://www.tradingview.com/support/solutions/43000595311-manage-alerts (consulted November 2026)"
    external:  true
  - title:     "What timezone is displayed in alerts?"
    locator:   "TradingView support, https://www.tradingview.com/support/solutions/43000691967-what-timezone-is-displayed-in-alerts (consulted November 2026)"
    external:  true
  - title:     "Concepts / Alerts"
    locator:   "Pine Script User Manual, TradingView, https://www.tradingview.com/pine-script-docs/concepts/alerts (consulted November 2026)"
    external:  true
  - title:     "Alert lists to be exported to CSV"
    locator:   "r/TradingView, https://www.reddit.com/r/TradingView/comments/ty84m0/alert_lists_to_be_exported_to_csv (user feature request)"
    external:  true
  - title:     "In Search of an Understandable Consensus Algorithm"
    locator:   "Ongaro, D. and Ousterhout, J. Proc. USENIX ATC 2014"
    external:  true
---

# Market Monitoring and Alerts: Charting Platforms as Prior Art

This evaluation examines how established charting and trading platforms
monitor markets on a user's behalf: how an alert is attached to a drawing,
where the monitoring runs, what triggers it, and how its result reaches the
user. It is prior art for Seed's financial utilities — the server-side chart
model in `application/app.chart`, and the figure vocabulary proposed in the
chart-editing Survey (SEED-0012).

The first version of Seed's financial utilities is limited to **monitoring and
alerts**. Placing orders through brokers' APIs is a later goal; the platforms'
order features are noted where they bear on the design, but they are not
scored. The asset classes in view are equities, forex and crypto.

The purpose is to learn, not to rank products. Seed is scored against the same
rubric, with each claim marked *realised* or *architectural*, as in the
Smalltalk Eval (SEED-0008).


## Method

Evidence is drawn from the platforms' published documentation and help pages,
cited in the front-matter and consulted in November 2026. Where a claim rests
on a third-party guide rather than on the vendor's own documentation, the text
says so. No hands-on testing was done. Seed is assessed at revision
`bf51998`.

The stance is **learning from prior art**, through the lens of Exact (cited):
the evaluation asks where each platform's description of a monitoring rule
lives, how many times that rule is described, and whether its behaviour is
stated or left to defaults.

Six systems are evaluated: TradingView; MetaTrader 4 and 5 with MetaQuotes'
Virtual Hosting; NinjaTrader 8; MotiveWave; ProRealTime with ProOrder; and the
webhook bridges that connect alerts to brokers. Seed is the seventh rendition.


## The Shared Scenario

Each system is walked through six tasks.

**S1 — Watch a sloped trend line, unattended.** Draw a trend line on an hourly
chart and be notified when a bar closes beyond it — including while the user's
computer is off.

**S2 — Edit the line after the alert exists.** Move one of the line's anchors.
Does the alert follow the new line, keep the old one, or stop?

**S3 — Watch a band of a retracement.** Draw a Fibonacci retracement and be
notified when price enters the band between its 38.2% and 61.8% levels.

**S4 — Backtest the drawing-based rule.** Ask how often S1's rule would have
fired over the past year, using the same rule that is watching live.

**S5 — Survive the loss of the monitoring host.** The machine or service that
evaluates the alert goes down. Does the alert still fire, and does it fire
exactly once?

**S6 — Apply the same rule across asset classes.** Use S1's rule on an equity
(with session gaps), a forex pair (trading through the week, quoted as bid and
ask), and a crypto pair (trading continuously).


## The Rubric

Table: Evaluation criteria M1–M10.

| Code | Criterion | What "strong" means |
|------|-----------|---------------------|
| M1 | Where monitoring runs | Independently of the user's machine and connection |
| M2 | Link between drawing and condition | Editing a drawing updates its alerts, or the alert pins a stated version |
| M3 | Condition vocabulary | Conditions on lines, channels, retracement levels and bands, and other figures, not only prices |
| M4 | Stated trigger semantics | Close versus intrabar, cross versus touch, and rearming are explicit parts of the rule |
| M5 | Backtesting from the same rule | The rule that watches live can be replayed over history unchanged |
| M6 | Delivery guarantees | Notifications are logged, retried, and not duplicated |
| M7 | Resilience to host failure | A failed host does not silence the alert or make it fire twice |
| M8 | Inspectability and portability | Rules can be read, versioned and moved, not only clicked |
| M9 | Asset-class coverage | Equities, forex and crypto, with their sessions and price bases |
| M10 | Extensibility | New conditions and figures can be added in a capable language |


## Rendition: TradingView

TradingView is a browser- and app-based charting platform with a very large
user base and broad coverage of equities, forex and crypto.

**M1 — Where monitoring runs: on TradingView's servers.** TradingView's support
pages state that alerts are server-side: they are created and triggered on
TradingView's servers and keep working with the chart closed.

**M2 — Link between drawing and condition: mixed.** A third-party guide states
that a drawing alert stays anchored to its drawing, so that moving or extending
the line updates the condition; this was not confirmed in TradingView's own
pages. Alerts on indicators behave differently: TradingView's documentation
states that if an indicator's parameter is changed after the alert is created,
the alert keeps using the old settings, and a guide on script alerts reports
that a script's source and inputs are saved as a snapshot when the alert is
created.

**M3 — Condition vocabulary: broad, per tool.** Alerts can be set on lines,
channels, rectangles, Fibonacci retracements and the anchored VWAP. Lines offer
crossing (up, down, or either) and greater or less than; channels and
rectangles offer entering, exiting, inside and outside; a Fibonacci alert can
trigger on crossing any active level or on entering the band between two
ratios. "Moving up/down" operators test movement over a number of bars.

**M4 — Stated trigger semantics: as settings.** Frequency is a setting —
reported as once, every time or once per bar, once per bar close, and once per
minute — together with an expiry. The choice between intrabar and bar-close
triggering is therefore made in a dialog rather than in the rule.

**M5 — Backtesting from the same rule: no, for drawings.** Strategies written
in Pine Script can be backtested; drawing alerts are a separate mechanism and,
as far as the sources examined show, cannot be replayed over history.

**M6 — Delivery guarantees: logged, not guaranteed.** Notifications go to the
app, a pop-up, e-mail, sound, or a webhook. Webhooks are limited to ports 80
and 443, are cancelled if the receiver takes more than three seconds, and "may
occasionally fail to reach the specified URL"; delivery status is shown in the
alert log. A third-party guide reports that an alert firing more than 15 times
in 3 minutes is stopped.

**M7 — Resilience: the vendor's.** Monitoring is as reliable as TradingView's
own infrastructure, whose redundancy is not documented to users. There is no
way for a user to run the same alert in a second place.

**M8 — Inspectability and portability: limited.** Alerts are objects in the
user's account, managed through the alert manager. The alert *log* — the
record of triggered alerts — can be exported to a CSV file, by TradingView's
own support pages. The alert definitions themselves cannot, as far as the
sources examined show: users ask for that export in TradingView's community
forum (a third-party source). Pine Script source can be read, but the rules
a user has set up live in the account, not in data the user can version or
move.

**M9 — Asset-class coverage: broad.** Equities, forex and crypto are all
covered, with data from many venues.

**M10 — Extensibility: Pine Script.** Custom conditions are written as Pine
Script indicators with `alertcondition()` or `alert()` calls, both described
in the Pine Script manual. Drawing tools themselves cannot, as far as is
known, be defined by users; this was not confirmed in the sources examined.

**Scenario walk-through.**

- **S1:** Strong — a server-side alert on the line, set to once per bar close.
- **S2:** Reportedly follows the edited line, by a third-party account.
- **S3:** Supported directly, as entering the band between two Fibonacci
  ratios.
- **S4:** Not possible for a drawing alert; the rule would have to be
  rewritten as a Pine Script strategy.
- **S5:** Depends entirely on TradingView's servers.
- **S6:** Covered; session handling is TradingView's.

**Steal:** Server-side monitoring as the default. Band conditions on
retracements, channels and rectangles. The alert log with delivery status.

**Reject:** Trigger semantics hidden in dialog settings. Drawing alerts that
cannot be backtested. Rules that live only in the vendor's account.


## Rendition: MetaTrader 4 and 5 with Virtual Hosting

MetaTrader is the dominant retail platform for forex and CFDs, distributed by
brokers. Automation is written as Expert Advisors (EAs) in MQL4 or MQL5.

**M1 — Where monitoring runs: in the terminal, or a hosted copy.** EAs and
indicators run inside the client terminal. MetaQuotes' Virtual Hosting rents a
"virtual terminal" on a hosting partner's server and migrates the terminal's
active environment to it: active charts with running EAs (16 charts on free
hosting, 32 on paid), their settings, and signal subscriptions. Charts with no
EA running are not migrated.

**M2 — Link between drawing and condition: through code.** An EA can read
chart objects and act on them; a "trend-line EA" that watches manually drawn
lines is a common pattern (from general knowledge of the platform, not
confirmed in the sources examined). The link is whatever the EA's code makes
it.

**M3 — Condition vocabulary: whatever is coded.** The terminal's own alerts are
price-based; conditions on drawings require an EA or indicator.

**M4 — Stated trigger semantics: in code.** Tick versus bar-close behaviour is
programmed in each EA.

**M5 — Backtesting from the same rule: for EAs.** EAs can be run in the
Strategy Tester; whether a rule that depends on manually drawn objects can be
tested depends on how the EA obtains those objects.

**M6 — Delivery guarantees: per EA.** Push notifications and e-mail are sent by
the terminal; guarantees are those the EA implements.

**M7 — Resilience: one hosted terminal.** Virtual Hosting removes the user's
machine from the loop, but the rented terminal is a single instance, and
MetaQuotes' rules state that the service makes no guarantees of the virtual
terminals' smooth operation.

**M8 — Inspectability and portability: code files.** EAs are source files
the user owns; chart objects travel in templates and profiles.

**M9 — Asset-class coverage: broker-dependent.** Strongest for forex and CFDs;
MetaTrader 5 also supports exchange instruments where the broker offers them;
crypto usually as broker CFDs.

**M10 — Extensibility: MQL.** A full programming language, at the cost of
writing monitoring logic as general code.

**Scenario walk-through.**

- **S1:** Possible with an EA on Virtual Hosting.
- **S2:** Depends on the EA: one that reads the object each bar follows edits,
  but edits made locally must be synchronised to the hosted terminal.
- **S3:** Must be coded.
- **S4:** Possible in the Strategy Tester for coded rules.
- **S5:** A single hosted terminal; no failover is described.
- **S6:** Forex is native; equities and crypto depend on the broker.

**Steal:** Moving the whole active environment to a server as a unit.

**Reject:** Monitoring logic that exists only as general-purpose code. A single
hosted instance as the answer to reliability.


## Rendition: NinjaTrader 8

NinjaTrader 8 is a Windows desktop platform popular for futures, with
automation in NinjaScript (C#).

**M1 — Where monitoring runs: in the open chart tab.** NinjaTrader's own blog
states that each alert is local to its chart tab and runs only while that tab
is open and enabled. A current third-party guide states that NinjaTrader 8
has no server-side alerts: closing the platform, or letting the computer
sleep, stops all monitoring.

**M2 — Link between drawing and condition: direct, while the tab lives.** Any
drawing object on the chart can be the condition object of an alert ("Cross
above Horizontal Line"). Moving the tab to another instrument drops alerts that
refer to drawing objects, according to a 2017 reply from NinjaTrader support
on its forum.

**M3 — Condition vocabulary: broad.** Conditions can compare data series,
indicators and drawing objects, through a condition builder.

**M4 — Stated trigger semantics: explicit, as settings.** Each alert has a
rearm type: never (the default, which fires once), on condition reversed, on
bar close, on a timer, remove after firing, or on reconnect. This is the most
explicit treatment of rearming among the platforms examined, though it is
still a setting rather than part of a described rule.

**M5 — Backtesting from the same rule: no, for alerts.** NinjaScript strategies
can be tested in the Strategy Analyzer; alerts are a separate mechanism. A
guide notes that alerts are checked every 200 milliseconds and are not meant
for accelerated market replay.

**M6 — Delivery guarantees: local.** Sound, pop-up, the Alerts Log, and e-mail
or messaging through configured share services — all sent from the running
platform.

**M7 — Resilience: none beyond the desktop.** A failed or sleeping computer
silences every alert.

**M8 — Inspectability and portability: workspace-bound.** Alerts live in the
workspace and chart tab.

**M9 — Asset-class coverage: futures first.** Futures are native; forex and
equities through supported connections.

**M10 — Extensibility: NinjaScript.** Drawing tools can declare that they
support alerts.

**Scenario walk-through.**

- **S1:** Works only while the platform runs.
- **S2:** The alert refers to the drawing object, so edits apply while the tab
  is open.
- **S3:** Possible with a suitable drawing object and condition.
- **S4:** Not for alerts.
- **S5:** Fails with the desktop.
- **S6:** Strongest for futures.

**Steal:** Rearming as an explicit, named choice — never, on reversal, on bar
close, on a timer.

**Reject:** Monitoring bound to a window.


## Rendition: MotiveWave

MotiveWave is a Java desktop platform for Windows, macOS and Linux, with a
mobile app, connecting to more than thirty brokers and data feeds. It is known
for the breadth of its analysis tools.

**M1 — Where monitoring runs: in the running desktop application.** Price
alerts do not need a chart open; study alerts execute in the context of a
chart and require it to be open. MotiveWave's own alert preferences warn that
"MotiveWave needs to be running in order to send an alert activated trade."
Cloud workspaces synchronise workspaces across computers, but do not run
alerts in the cloud.

**M2 — Link between drawing and condition: direct.** A *component alert* is
created by right-clicking a component such as a trend line and choosing
Create Alert; the condition can compare price or a study value with the line —
for example, a moving average crossing a trend line. The alert is drawn on the
chart and can be edited there.

**M3 — Condition vocabulary: the widest set of tools examined.** MotiveWave's
editions list trend lines, channels, forks, cycles, regression tools, circles,
and Fibonacci retracements, extensions, expansions, circles, arcs and fans,
along with Elliott Wave, Gann and harmonic tools. Not every component can carry
an alert; the documentation says "some components".

**M4 — Stated trigger semantics: explicit, as settings.** Operators are
crosses, crosses above, crosses below, and touches. "Trigger Multiple" keeps
the alert armed after it fires, and "Multiple per Bar" allows more than one
trigger per bar. A time-in-force section sets an expiry and up to two daily
sessions in which the alert is active.

**M5 — Backtesting from the same rule: for strategies.** Strategies written
with the Java SDK respond to bar events (`onBarOpen`, `onBarUpdate`,
`onBarClose`) and can be backtested in the PRO and Ultimate editions. Alerts
are a separate mechanism.

**M6 — Delivery guarantees: local.** Alert history window, sound, and e-mail
with an optional chart image; alert history is also shown on the chart, where
each trigger is marked.

**M7 — Resilience: none beyond the desktop.** Alerts depend on the running
application.

**M8 — Inspectability and portability: workspace-bound.** Alerts live in the
workspace; studies and strategies are Java code the user owns.

**M9 — Asset-class coverage: broad.** Equities, forex, futures, options and
crypto, depending on the connected broker or feed.

**M10 — Extensibility: the Java SDK.** All built-in studies and strategies are
written with the SDK, and their sources are available as examples.

**Scenario walk-through.**

- **S1:** Works while the application runs.
- **S2:** The alert belongs to the component, so editing the component edits
  the condition.
- **S3:** Retracements are among the tools; whether a band between two levels
  can be the condition was not confirmed.
- **S4:** Not for alerts; a strategy would have to be written.
- **S5:** Fails with the desktop.
- **S6:** Broad, through its many connections.

**Steal:** The breadth of the figure set as a target for Seed's vocabulary.
Alerts drawn on, and recorded on, the chart where they apply. Time-in-force
sessions as part of an alert.

**Reject:** Monitoring bound to a running desktop application.


## Rendition: ProRealTime with ProOrder

ProRealTime is a charting platform offered through partner brokers. ProOrder is
its automated-trading module.

**M1 — Where monitoring runs: on ProRealTime's servers.** ProRealTime describes
ProOrder as "100% server-side": a started system runs autonomously on its
servers, even after the platform is closed, and its servers are directly
connected to those that execute orders.

**M2 — Link between drawing and condition: not examined.** ProOrder systems are
written in the ProBuilder language or with no-code tools. The sources examined
do not present drawings as the source of ProOrder conditions; ProRealTime's
own drawing alerts were not examined.

**M3 — Condition vocabulary: code.** Whatever ProBuilder can express.

**M4 — Stated trigger semantics: in code.** Systems are evaluated as bars
arrive.

**M5 — Backtesting from the same rule: yes.** The same ProBuilder code is
backtested in ProBacktest and run live in ProOrder — the strongest instance of
one rule serving both uses among the platforms examined.

**M6 — Delivery guarantees: reports and confirmations.** Order confirmations
and performance reports are sent by e-mail or to a phone.

**M7 — Resilience: the vendor's, and the broker's.** Server-side execution
removes the user's machine, but not the dependence on the broker. A
third-party vendor of ProOrder systems, A+ Algos, reports that IG had major
IT problems in September 2025, and that its own systems on IG largely did
not trade after 10 September that month.

**M8 — Inspectability and portability: code, with an expiry.** Systems are
code. ProRealTime's conditions of execution state that running systems have
a common validity date, and that ProOrder may stop them automatically if the
user does not extend it before that date; an IG guide says the same.

**M9 — Asset-class coverage: broker-dependent.** Through partner brokers,
commonly CFDs.

**M10 — Extensibility: ProBuilder.** A platform-specific language.

**Scenario walk-through.**

- **S1:** Possible as a coded system rather than a drawing.
- **S2:** Not applicable; the line is in code.
- **S3:** Must be coded.
- **S4:** Strong — the same code is backtested.
- **S5:** Depends on ProRealTime's and the broker's infrastructure.
- **S6:** Depends on the partner broker.

**Steal:** One rule for backtest and live. Safeguards attached to a running
system — a maximum position size and a maximum number of orders per day — for
the later execution goal. Expiry as an explicit property of a running rule.

**Reject:** Conditions that can only be written as code in a platform-specific
language.


## Rendition: Webhook Bridges

Services such as TradersPost, PineConnector and TheConnector receive
TradingView webhooks and turn them into broker orders. They matter here mainly
as evidence of how alerts leave a platform.

**M1 — Where monitoring runs: elsewhere.** The bridge does not monitor; it
receives messages from a platform that does. TheConnector's own page notes that
TradingView "executes nothing at your broker", and that its robot must be kept
running in MetaTrader or cTrader.

**M6 — Delivery guarantees: inherited.** A bridge receives whatever the
platform's webhook delivers, under the platform's constraints, and the logic of
a trade is split between the alert's message text, the bridge's settings and
the broker.

**M8 — Inspectability and portability: fragmented.** No single place states
the rule.

The remaining criteria do not apply.

**Steal:** Tracking each message from receipt to its outcome.

**Reject:** A rule spread across three systems joined by text messages.


## Rendition: Seed

Seed's financial utilities are assessed at revision `bf51998`. Most of what
follows is *architectural*: it draws on the chart-editing Survey
(SEED-0012), the branch Survey (SEED-0009) and Vox
(VOX-DRAFT-vox).

**M1 — Where monitoring runs: a server image, by design.** Seed runs as a
server process already; a monitoring branch that evaluates figures against
arriving bars needs no user machine (*architectural*).

**M2 — Link between drawing and condition: one description.** A figure is
defined once by `define-chart-figure`, and its geometry is evaluated in Lisp as
well as drawn. An alert refers to the figure instance, so editing the figure
changes the condition by construction; pinning an alert to a revision of the
figure is an explicit choice (*architectural*). Figures are already stored as
Lisp data on the server (*realised*), and `app.chart`'s `plot` method begins
comparing lines with new data, unfinished (*realised* in part). These are the
figures of the chart-entity editor in `systems/abcd`, the editor whose
structured parameters SEED-0006 evaluates in its scenario S1; a watcher would
refer to the same figure instances that editor creates.

**M3 — Condition vocabulary: from the figure families.** Because retracements,
channels and concentric circles share one form — a base, a transform and a
ratio list — "crossing a level" and "entering the band between two ratios"
apply to all of them uniformly (*architectural*).

**M4 — Stated trigger semantics: part of the rule.** Close versus intrabar,
cross versus touch, rearming, sessions and expiry would be parts of the
watcher's form, checked when it is defined (*architectural*):

```lisp
(watch (band fib-1 38.2 61.8)
  :when      (entering :close)
  :evaluate  :bar-close
  :rearm     :on-reversal
  :sessions  :instrument
  :expires   nil
  :then      ((notify :push) (notify :email)))
```

**M5 — Backtesting from the same rule: by replay.** SEED-0009 proposes
logging decoded input as canonical Vox data, replayable and hashable. Replaying
historical bars through the same watcher is a backtest of the live rule
(*architectural*).

**M6 — Delivery guarantees: effects with identities.** A notification is a
queued effect (SEED-0009) carrying a key — the watcher, the bar and the
condition — so a retried delivery is recognisable as a repeat
(*architectural*).

**M7 — Resilience: several hosts.** See "Monitoring across hosts" in the
Synthesis (*architectural*).

**M8 — Inspectability and portability: data in files.** Figures are already
Lisp data in version-controlled analysis files (*realised*). Today those
files are read with `load` and `from-system-file`
(`systems/abcd/seed.lisp:init-chart-entities@bf51998`) and new figures are
written back through a string templater; reading and writing them through
Philo (SEED-0001), as SEED-0012's persistence step proposes, is
*architectural*. So are watchers as data in the same files, and a branch's
`describe` reporting what is being watched.

**M9 — Asset-class coverage: not yet built.** Equities, forex and crypto
differ in sessions (equity sessions and gaps, forex through the week, crypto
continuously) and in price basis (last trade, or bid and ask). These would be
properties of the instrument and the series, not of each watcher
(*architectural*). There is no data feed yet.

**M10 — Extensibility: Lisp.** New figures and conditions are definitions in
Lisp, not code in a platform language (*architectural*).

**Scenario walk-through.**

- **S1:** The design case: a watcher on a figure, in a server image.
- **S2:** Edits flow through by construction, or are pinned deliberately.
- **S3:** A band condition on a figure family.
- **S4:** Replay of the logged bars through the same watcher.
- **S5:** Replicated watchers on several hosts (Synthesis).
- **S6:** Sessions and price basis from the instrument, the rule unchanged.

None of this is built. Today Seed has figures as data, a chart editor, a
partial server-side chart model, and a branch system in one image.


## Comparison

Table: Summary scores per criterion. ● strong; ◐ partial; ○ weak; – not applicable. Seed's column scores its design, under one rule: what is not built scores at most ◐, and ● is reserved for what is realised.

| Criterion | TradingView | MetaTrader + VH | NinjaTrader 8 | MotiveWave | ProRealTime | Bridges | Seed (design) |
|---|---|---|---|---|---|---|---|
| M1 Where it runs | ● vendor servers | ◐ hosted terminal | ○ open chart tab | ○ running app | ● vendor servers | – | ◐ server image, unbuilt |
| M2 Drawing link | ◐ reportedly follows | ◐ via code | ◐ while tab lives | ● component alerts | – | – | ◐ one description, unbuilt |
| M3 Conditions | ● per tool, bands | ◐ coded | ● builder | ● widest tool set | ◐ coded | – | ◐ families, unbuilt |
| M4 Trigger semantics | ◐ settings | ◐ coded | ◐ explicit rearm | ◐ explicit options | ◐ coded | – | ◐ part of the rule, unbuilt |
| M5 Same-rule backtest | ○ not for drawings | ◐ for EAs | ○ not for alerts | ○ not for alerts | ● same code | – | ◐ by replay, unbuilt |
| M6 Delivery | ◐ logged, may fail | ◐ per EA | ○ local | ○ local | ◐ reports | ○ inherited | ◐ keyed effects, unbuilt |
| M7 Resilience | ◐ vendor's | ◐ one instance | ○ desktop | ○ desktop | ◐ vendor's and broker's | ○ chained | ◐ multi-host, unbuilt |
| M8 Inspectable | ○ account objects; log exports | ◐ code files | ○ workspace | ○ workspace | ◐ code | ○ fragmented | ◐ figures in files; watchers unbuilt |
| M9 Asset classes | ● broad | ◐ forex first | ◐ futures first | ● broad | ◐ via brokers | – | ○ no feed yet |
| M10 Extensibility | ◐ Pine Script | ● MQL | ● NinjaScript | ● Java SDK | ◐ ProBuilder | – | ◐ Lisp definitions, unbuilt |

Two patterns stand out. First, **no platform describes a drawing-based rule
once**: the drawing, the alert, the strategy and the backtest are separate
mechanisms, and only ProRealTime serves backtest and live from one
description — for code, not drawings. Second, **monitoring that survives the
user's machine is a vendor's service, not a property of the rule**: where it
exists (TradingView, ProRealTime, MetaTrader's hosting), it runs in one place
the user cannot replicate.

Seed's design answers both in principle; it has built neither. Under the
rule in the caption, nothing in Seed's column scores ●: its cells record
where the design aims and what it would cover, not a claim to match shipped
products. The rendition above gives the design's case criterion by
criterion.


## Synthesis

### What Seed should adopt

**From TradingView: server-side by default, and band conditions.** Monitoring
should never depend on the user's machine, and conditions on figures should
include entering, exiting, inside and outside a band, not only crossing. The
alert log with delivery status is the model for a watcher's history.

**From NinjaTrader and MotiveWave: named trigger behaviour.** NinjaTrader's
rearm types and MotiveWave's touches, trigger-multiple, per-bar and
time-in-force options are the vocabulary Seed's watcher form should state
explicitly, with defaults chosen and documented rather than inherited.

**From MotiveWave: the breadth of figures.** MotiveWave's tool set is a
practical inventory of what technical analysts draw, and a test of whether the
figure vocabulary's universals reach that far.

**From ProRealTime: one rule for backtest and live.** Replay of logged bars
through the live watcher is Seed's form of the same guarantee. ProOrder's
safeguards and expiry are models for the later execution goal.

### What Seed should keep as its own

- **One description per rule.** A figure's definition drives its drawing, its
  persistence, its property editors and its evaluation in Lisp; a watcher
  refers to the figure instead of copying it.
- **Trigger semantics in the rule.** What a watcher does at bar close or
  intrabar, and how it rearms, are part of its form and checked when it is
  defined (Exact's Implied Checks).
- **Rules as data the user owns.** Figures and watchers are versioned files,
  not objects inside a vendor's account.

### Monitoring across hosts

Seed's branches can call one another across images through `grow` over Vox
interlinks (SEED-0009, VOX-DRAFT-vox). That makes possible a design no
platform examined offers to its users: the same watchers running on several
hosts at different providers, so that the loss of one provider does not
silence them. The design questions are these.

**Agreeing on the input.** Hosts with separate market-data feeds will see
slightly different bars — different last trades, different moments of a bar's
close — and may disagree about whether a condition was met. Two answers: one
host produces the canonical bar stream and replicates it to the others as a
log, so every host evaluates the same bars; or each host evaluates its own
feed and the hosts reconcile by key. The first gives agreement; the second
gives independence from any one feed.

**Firing exactly once.** Every trigger has a natural key: the watcher, the
bar, and the condition. If each host keys its notifications that way and the
notification sinks — or the hosts among themselves, by `grow` — discard keys
they have already seen, several hosts can watch without the user receiving
several notifications. For alerts, at-least-once delivery with
de-duplication by key is enough.

**Detecting failure and choosing who acts.** Hosts exchange heartbeats; when
only one host should act — as orders will require — a host holds a lease, and
a quorum of hosts decides who holds it. Three hosts tolerate the loss of one.
Consensus algorithms such as Raft (Ongaro and Ousterhout, 2014) solve this
problem in general; Erlang/OTP's distribution and supervision trees
(SEED-0010) are the closest model in a running system.

**Running the same rule everywhere.** Watchers are data, so each host can
report a hash of the watchers it runs, and a host whose rules differ from the
others' can refuse to act until they agree — a check that follows from the
description, in Exact's terms.

**What execution will add.** Placing orders raises the bar from at-most-once
notifications to exactly-once orders: one host at a time must own each order,
and the order should carry a client-assigned identifier so that a retry is
recognised as a repeat. Several brokers' APIs accept such identifiers; which
ones, and with what guarantees, is for the execution stage to establish.

### Where Seed is not competing

Seed will not match these platforms' breadth of data, studies, mobile apps and
broker integrations. Its claim is narrower: that a rule stated once, as data,
can be drawn, edited, watched, replayed and replicated without being described
again — and that this regularity is a better foundation for monitoring that
must be trusted than any single vendor's service.


## Appendix — Source Map

Table: Where the evidence for each rendition comes from, and its standing. "Not confirmed" claims rest on general knowledge and were not checked against the sources examined.

| Rendition | Vendor documentation | Third-party sources | Not confirmed |
|---|---|---|---|
| TradingView | Server-side alerts; drawing-alert conditions; indicator-parameter snapshot; webhook limits; alert log export to CSV; Pine Script's `alert()` and `alertcondition()` | Frequency options; drawing alerts following edits; 15 triggers in 3 minutes; alert definitions not exportable (user feature requests) | Backtesting of drawing alerts; users unable to define drawing tools |
| MetaTrader | Virtual Hosting migration rules | — | EAs reading chart objects; backtesting EAs in the Strategy Tester |
| NinjaTrader 8 | Drawing objects as conditions; alerts local to the chart tab; drawing alerts dropped on changing instrument (2017 support reply) | No server-side alerts; rearm types; 200 ms checking | Strategies tested in the Strategy Analyzer |
| MotiveWave | Alert types and options; "must be running" warning; SDK strategies; tool list | — | Band conditions on retracements; "more than thirty brokers and data feeds" |
| ProRealTime | Server-side ProOrder; safeguards; validity date and automatic stopping | IG's September 2025 IT problems (A+ Algos) | Drawing alerts |
| Bridges | TheConnector's page | — | — |
| Synthesis | — | — | Brokers' APIs accepting client-assigned order identifiers; the venue of the Raft paper, cited from memory |
