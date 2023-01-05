double numMap(value,fromLow,fromHigh,toLow,toHigh){
  return (toHigh-toLow)*(value-fromLow) / (fromHigh-fromLow) + toLow;
}

double constrain(double x, double a, double b){
  if (x < a){
    return a;
  } else if (x > b){
    return b;
  }else{
    return x;
  }
}
