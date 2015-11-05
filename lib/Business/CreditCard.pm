unit module Business::CreditCard;

# https://en.wikipedia.org/wiki/Bank_card_number
sub _is_enRoute($num) {
    $num.starts-with('2014') || $num.starts-with('2149');
}

sub cardtype($num is copy) is export {
    $num = $num.subst(/<[\s\-]>+/, '', :g);

    return 'Visa' if $num.starts-with('4') and $num.chars ~~ [13, 16];
    return 'MasterCard' if $num ~~ /^5<[1..5]>/ and $num.chars == 16;
    return 'AmericanExpress' if $num ~~ /^3<[47]>/ and $num.chars == 15;
    return 'ChinaUnionPay' if $num.starts-with('62') and $num.chars >= 16 and $num.chars <= 19;
    return 'enRoute' if _is_enRoute($num);

    return 'DinersClub' if ( $num ~~ /^30<[0..5]>/ || $num.starts-with('309') || $num ~~ /^3<[689]>/)
        and $num.chars >= 14 and $num.chars <= 16;

    # 6011, 622126-622925, 644-649, 65
    return 'Discover' if ( $num.starts-with('6011') || $num ~~ /^<[622126..622925]>/ || $num ~~ /^<[644..649]>/ || $num.starts-with('65') )
        and $num.chars == 16;

    return 'InterPayment' if $num.starts-with('639') and $num.chars >= 16 and $num.chars <= 19;
    return 'InstaPayment' if $num ~~ /^<[637..639]>/ and $num.chars == 16;
    return 'JCB' if $num ~~ /^<[3528..3589]>/ and $num.chars == 16;

    return 'Dankort' if $num.starts-with('5019') and $num.chars == 16;

    # 50, 56-69
    return 'Maestro' if ( $num.starts-with('50') || $num ~~ /^<[56..69]>/ )
        and $num.chars >= 12 and $num.chars <= 19;

    return 'UATP' if $num.starts-with('1') and $num.chars == 15;

    return '';
}

sub validate($num is copy) is export {
    if _is_enRoute($num) {
        return True;
    }

    $num = $num.subst(/\D+/, '', :g);

    my $sum = 0; my $even = False;
    for (0 .. $num.chars - 1).reverse -> $i {
        my $char = substr($num, $i, 1).Int;
        $char *= 2 if $even;
        $char -= 9 if $char > 9;
        $sum  += $char;
        $even = ! $even;
    }

    return ($sum % 10) == 0;
}