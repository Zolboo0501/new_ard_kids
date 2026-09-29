import '../../../app/kid_profile.dart';

/// One stock in the portfolio on "Миний өв".
class Holding {
  const Holding({
    required this.name,
    required this.ticker,
    required this.mark,
    required this.quantity,
    required this.value,
    required this.change,
  });

  final String name;

  /// As the exchange lists it, e.g. `AAPL`, `МХБ: APU`.
  final String ticker;

  /// The short letters drawn in the row's tile.
  final String mark;

  /// e.g. `0.08 хувьцаа`.
  final String quantity;

  /// Current value in ₮.
  final int value;

  /// Change since bought, in percent.
  final double change;
}

/// Mock portfolio. The values add up to [Balances.stocks], the total Home
/// shows for this account.
const mockHoldings = [
  Holding(
    name: 'Apple',
    ticker: 'AAPL',
    mark: 'AAPL',
    quantity: '0.08 хувьцаа',
    value: 60800,
    change: 14.2,
  ),
  Holding(
    name: 'Disney',
    ticker: 'DIS',
    mark: 'DIS',
    quantity: '0.12 хувьцаа',
    value: 39800,
    change: 8.5,
  ),
  Holding(
    name: 'АПУ ХК',
    ticker: 'МХБ: APU',
    mark: 'АПУ',
    quantity: '30 ширхэг',
    value: 28500,
    change: 5.1,
  ),
  Holding(
    name: 'Roblox',
    ticker: 'RBLX',
    mark: 'RBLX',
    quantity: '0.04 хувьцаа',
    value: 13400,
    change: -1.8,
  ),
];

/// What was put in, the gain on it, and dividends received, in ₮. Invested
/// plus gain is [Balances.stocks].
const portfolioInvested = 126400;
const portfolioGain = 16100;
const portfolioDividends = 2200;
